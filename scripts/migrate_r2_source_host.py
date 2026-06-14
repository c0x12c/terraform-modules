#!/usr/bin/env python3

import argparse
import copy
import io
import json
import os
import re
import sys
import tarfile


REGISTRY_HOST = "terraform.c0x12c.com"


def build_source_re(org):
    return re.compile(
        r'^(\s*source\s*=\s*")(' + re.escape(org) + r'/[^"/]+/[^"/]+)((?://[^"]*)?)(".*)$'
    )


def rewrite_tf_text(text, source_re):
    output = []
    n_changed = 0
    for line in text.splitlines(True):
        newline = ""
        body = line
        if line.endswith("\r\n"):
            body = line[:-2]
            newline = "\r\n"
        elif line.endswith("\n"):
            body = line[:-1]
            newline = "\n"
        match = source_re.match(body)
        if not match:
            output.append(line)
            continue
        output.append(
            "%s%s/%s%s%s%s"
            % (
                match.group(1),
                REGISTRY_HOST,
                match.group(2),
                match.group(3),
                match.group(4),
                newline,
            )
        )
        n_changed += 1
    return "".join(output), n_changed


def rewrite_tarball(blob, source_re):
    changed_files = []
    total_changed = 0
    source = io.BytesIO(blob)
    output = io.BytesIO()

    with tarfile.open(fileobj=source, mode="r:gz") as src:
        members = src.getmembers()
        rewritten_members = []
        for member in members:
            member_copy = copy.copy(member)
            fileobj = src.extractfile(member)
            payload = None
            if fileobj is not None:
                payload = fileobj.read()
            if member.isreg() and member.name.endswith(".tf"):
                text = payload.decode("utf-8")
                new_text, n_changed = rewrite_tf_text(text, source_re)
                if n_changed:
                    changed_files.append(member.name)
                    total_changed += n_changed
                    payload = new_text.encode("utf-8")
                    member_copy.size = len(payload)
            rewritten_members.append((member_copy, payload))

        if total_changed == 0:
            return None, []

        with tarfile.open(fileobj=output, mode="w:gz") as dst:
            for member, payload in rewritten_members:
                if payload is None:
                    dst.addfile(member)
                    continue
                dst.addfile(member, io.BytesIO(payload))

    return output.getvalue(), changed_files


def iter_published(client, bucket):
    body = client.get_object(Bucket=bucket, Key="index.json")["Body"].read()
    index = json.loads(body.decode("utf-8"))
    published = []
    for key, versions in index.items():
        for version in versions:
            published.append((key, version))
    return published


def migrate(client, bucket, org, execute):
    source_re = build_source_re(org)
    summary = {"scanned": 0, "rewritten": 0, "skipped": 0}
    for key, version in iter_published(client, bucket):
        summary["scanned"] += 1
        object_key = "modules/%s/%s.tar.gz" % (key, version)
        blob = client.get_object(Bucket=bucket, Key=object_key)["Body"].read()
        new_blob, changed_files = rewrite_tarball(blob, source_re)
        if new_blob is None:
            print("skip %s %s (already qualified / no bare sources)" % (key, version))
            summary["skipped"] += 1
            continue
        print("rewrite %s %s (%s files)" % (key, version, len(changed_files)))
        if execute:
            client.put_object(
                Bucket=bucket,
                Key=object_key,
                Body=new_blob,
                ContentType="application/gzip",
            )
        summary["rewritten"] += 1
    return summary


def build_client():
    import boto3

    return boto3.client("s3", endpoint_url=os.environ["R2_ENDPOINT"])


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description="Rewrite already-published R2 Terraform module tarballs so bare "
        "registry sources become host-qualified self-hosted registry sources."
    )
    parser.add_argument("--r2-bucket", required=True)
    parser.add_argument("--org", default="c0x12c")
    parser.add_argument("--execute", action="store_true")
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv or sys.argv[1:])
    if args.execute:
        print(
            "NOTE: re-uploads overwrite live R2 objects under the same key; ensure "
            "bucket versioning is enabled or you have a snapshot before proceeding."
        )
    client = build_client()
    migrate(client, args.r2_bucket, args.org, args.execute)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
