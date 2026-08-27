# Restoring the module registry from a snapshot

A scheduled job copies the registry bucket to a GitHub artifact once a day. This
is the procedure for putting it back.

**Read this first.** A snapshot restores OBJECTS ONLY - `index.json` and the
module tarballs. If the Cloudflare account itself is gone, so are the Worker and
the DNS record for `terraform.c0x12c.com`, and neither comes back from a bucket
copy. In that case, rebuild the Worker and the domain first; the snapshot is only
useful once there is a bucket to restore into.

## 1. Get a snapshot

```
gh run list --workflow registry-snapshot.yml --limit 10
gh run download <run-id> --name registry-snapshot-<date>
```

Artifacts are kept for 30 days. Pick a run from before whatever went wrong -
the most recent snapshot may already contain the damage.

## 2. Check what it holds

`manifest.json` records the object count, total bytes, and a sha256 per object.
Compare its `generated_at` and `object_count` against what you expect before
going further.

## 3. Dry run

```
export R2_ENDPOINT=https://<account>.r2.cloudflarestorage.com
export AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... AWS_DEFAULT_REGION=auto
python3 scripts/registry_snapshot.py restore --bucket <bucket> --from ./snapshot
```

This writes nothing. It verifies every file against its recorded checksum and
reports what it would upload, so a corrupted artifact fails here rather than
halfway through a real restore.

## 4. Apply

```
python3 scripts/registry_snapshot.py restore --bucket <bucket> --from ./snapshot --apply
```

Restoring needs a credential with write access; the snapshot job's own
credential is read-only by design.

## 5. Confirm

`terraform init` against a module you know was affected is the check that
matters - the protocol endpoints can look healthy while a tarball is missing.
