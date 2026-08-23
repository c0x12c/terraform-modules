#!/usr/bin/env python3
"""Render this module's `local.manifest` across a case matrix and dump each PARSED result as
canonical JSON, so a refactor can be proven not to change what the module sends to Helm.

The manifest is rendered in an isolated scratch copy holding only the module's `locals` and
`variable` blocks, so no provider, data source or AWS credential is involved.

Capture a baseline from the current checkout, change the module, then compare:

    ./tests/render-manifest.py . /tmp/before.json
    # ...edit the module...
    ./tests/render-manifest.py . /tmp/after.json
    ./tests/render-manifest.py --compare /tmp/before.json /tmp/after.json

The compare must print `N cases, 0 differ`. Key order and block-scalar-vs-escaped-string are
ignored, as is per-line indentation inside the Slack card bodies - those are all encoding detail
that Helm and ArgoCD do not observe. Anything else is a real change.

Requires `terraform` on PATH and PyYAML.
"""
import json, os, re, shutil, subprocess, sys, tempfile
import yaml

CASES = {
    "webhook_sub_on":  {"slack_webhook_url": "https://example.invalid/hook", "enable_default_subscription": "true"},
    "webhook_sub_off": {"slack_webhook_url": "https://example.invalid/hook", "enable_default_subscription": "false"},
    "token_chan_on":   {"slack_token": "faketok", "default_notification_channel": "#chan", "enable_default_subscription": "true"},
    "token_chan_off":  {"slack_token": "faketok", "default_notification_channel": "#chan", "enable_default_subscription": "false"},
    "token_no_chan":   {"slack_token": "faketok", "default_notification_channel": ""},
    "no_slack":        {},
    "node_sel_tols":   {"node_selector": '{"role":"platform"}',
                        "tolerations": '[{key="dedicated",operator="Equal",value="platform",effect="NoSchedule"}]'},
    "not_managed":     {"enabled_managed_in_cluster": "false"},
    "no_ssd":          {"server_side_diff": "false"},
    "oauth_creds":     {"external_github_oauth_creds": '{acme={client_id="cid",client_secret="csec",organization="acme"}}'},
    "ext_cluster_min": {"external_clusters": '{dev={server="https://d.example",config={aws_auth_config={cluster_name="dev",role_arn="arn:aws:iam::1:role/r"},tls_client_config={ca_data="Y2E="}}}}'},
    # Exercises the custom-template override path - the module must prefer the caller's string
    # over its own sample card, and still fall back to the sample for every unset key.
    "custom_template":  {"notification_templates": '{app_deployed="[{\\"title\\": \\"CUSTOM\\"}]"}'},
    "ext_cluster_full":{"external_clusters": '{dev={server="https://d.example",assume_role="arn:aws:iam::1:role/a",namespace="ns",cluster_resources=true,labels={env="dev"},annotations={note="n"},config={aws_auth_config={cluster_name="dev",role_arn="arn:aws:iam::1:role/r"},tls_client_config={insecure=true,ca_data="Y2E="}}}}'},
}
# Required variables are stubbed to `any` in the scratch root, and terraform parses a -var value
# for an any-typed variable as an HCL expression - so these must carry their own quotes.
# Every module variable the manifest reads that has NO default must appear here. One that is
# missing gets stubbed to null in the scratch root and the render aborts partway - the render
# function raises on that rather than returning a truncated manifest, so add the new variable
# here when a render starts failing after someone adds a required input.
BASE_VARS = {
    "domain_name": '"example.com"',
    "in_cluster_name": '"in-cluster"',
    "oidc_github_client_id": '"oidc-client-id"',
    "oidc_github_client_secret": '"oidc-client-secret"',
    "oidc_github_organization": '"acme"',
}

TOP_BLOCK = re.compile(r'^(locals|variable|terraform|resource|data|module|provider|output)\b')


def keep_locals_and_variables(text):
    """Return only the top-level `locals` and `variable` blocks, by brace depth."""
    out, lines, i = [], text.split("\n"), 0
    while i < len(lines):
        m = TOP_BLOCK.match(lines[i])
        if not m:
            i += 1
            continue
        start, depth, heredoc = i, 0, None
        while i < len(lines):
            if heredoc:
                # Inside a heredoc, braces are DATA - the Slack card templates are full of Go
                # template `{{ .app... }}`, which unbalances a naive depth count and silently
                # truncates the locals block (the notifications section vanished this way).
                if lines[i].strip() == heredoc:
                    heredoc = None
                i += 1
                continue
            m2 = re.search(r'<<-?([A-Za-z_][A-Za-z0-9_]*)\s*$', lines[i])
            if m2:
                heredoc = m2.group(1)
                i += 1
                continue
            depth += lines[i].count("{") - lines[i].count("}")
            i += 1
            if depth <= 0 and i > start:
                break
        if m.group(1) in ("locals", "variable"):
            out.extend(lines[start:i])
            out.append("")
    return "\n".join(out)


def stub_required(text):
    """Required variables become `any`/null so the scratch root needs no values for the ones
    the manifest never reads. Cases pass the ones it does read explicitly."""
    blocks = re.split(r'(?m)^(?=variable ")', text)
    for n, b in enumerate(blocks):
        if not b.startswith('variable "') or re.search(r'(?m)^\s*default\s*=', b):
            continue
        # A type constraint can span many lines (object({...})), so drop it by bracket depth.
        kept, lines, i = [], b.split("\n"), 0
        while i < len(lines):
            if re.match(r'^\s*type\s*=', lines[i]):
                depth = 0
                while i < len(lines):
                    depth += sum(lines[i].count(c) for c in "({[") - sum(lines[i].count(c) for c in ")}]")
                    i += 1
                    if depth <= 0:
                        break
                kept.append("  type = any")
                continue
            kept.append(lines[i])
            i += 1
        b = "\n".join(kept)
        blocks[n] = b.rstrip()[:-1].rstrip() + "\n  default = null\n}\n\n"
    return "".join(blocks)


def build_scratch(module_dir):
    d = tempfile.mkdtemp(prefix="argocd-render-")
    body = "".join(
        keep_locals_and_variables(open(os.path.join(module_dir, f)).read()) + "\n"
        for f in sorted(os.listdir(module_dir)) if f.endswith(".tf")
    )
    open(os.path.join(d, "main.tf"), "w").write(stub_required(body))
    # `path.module` resolves to the scratch root, so anything the manifest loads by that path -
    # the Slack card .tpl - has to come along or templatefile() fails with "no file exists".
    assets = os.path.join(module_dir, "templates")
    if os.path.isdir(assets):
        shutil.copytree(assets, os.path.join(d, "templates"))
    subprocess.run(["terraform", "init", "-backend=false", "-input=false"],
                   cwd=d, capture_output=True, check=True)
    return d


def render(scratch, overrides):
    args = ["terraform", "console", "-no-color"]
    for k, v in {**BASE_VARS, **overrides}.items():
        args += ["-var", f"{k}={v}"]
    p = subprocess.run(args, cwd=scratch, input="nonsensitive(local.manifest)\n",
                       capture_output=True, text=True)
    # Terraform prints a PARTIAL manifest and still exits 0 when a template interpolation hits a
    # null - the render silently truncates at that point. Treat any stderr diagnostic as fatal,
    # or the snapshot is a prefix of the manifest and every comparison against it passes vacuously.
    if "Error:" in p.stderr or p.returncode != 0:
        raise SystemExit(f"render failed for {overrides}\n{p.stderr[:800]}")
    lines = p.stdout.split("\n")
    try:
        i = next(k for k, l in enumerate(lines) if l.strip() == "<<EOT")
        e = max(k for k, l in enumerate(lines) if l.strip() == "EOT")
    except (StopIteration, ValueError):
        raise SystemExit(f"render failed\nstdout:\n{p.stdout[:800]}\nstderr:\n{p.stderr[:800]}")
    doc = yaml.safe_load("\n".join(lines[i + 1:e]))
    missing = {"global", "server", "dex", "configs", "notifications"} - set(doc)
    if missing:
        raise SystemExit(f"manifest truncated for {overrides}: missing {sorted(missing)}")
    return doc


def normalise(node):
    """A yaml value that is itself yaml (the notifier/template block scalars) is parsed too,
    so a `|` block and an escaped one-line string compare equal."""
    if isinstance(node, dict):
        return {k: normalise(v) for k, v in node.items()}
    if isinstance(node, list):
        return [normalise(v) for v in node]
    if isinstance(node, str) and ("\n" in node or node.lstrip().startswith("{")):
        for loader in (json.loads, yaml.safe_load):
            try:
                parsed = loader(node)
                if isinstance(parsed, (dict, list)):
                    return normalise(parsed)
            except Exception:
                pass
        # A Slack card body is not valid JSON until Go-template expansion, so it cannot be
        # parsed and compared structurally. Dropping per-line leading/trailing whitespace makes
        # the comparison blind to indentation - which is exactly what removing indent() changes
        # - while still catching any edit INSIDE a quoted string, where the spaces are content.
        if "\n" in node:
            return "\n".join(l.strip() for l in node.split("\n") if l.strip())
    return node


def main():
    if sys.argv[1] == "--compare":
        a, b = (json.load(open(p)) for p in sys.argv[2:4])
        bad = [c for c in sorted(set(a) | set(b)) if a.get(c, "<missing>") != b.get(c, "<missing>")]
        for c in bad:
            print(f"DIFF {c}")
            print("  before:", json.dumps(a.get(c))[:400])
            print("  after :", json.dumps(b.get(c))[:400])
        print(f"{len(a)} cases, {len(bad)} differ")
        sys.exit(1 if bad else 0)

    module_dir, out = sys.argv[1], sys.argv[2]
    scratch = build_scratch(module_dir)
    try:
        snap = {name: normalise(render(scratch, ov)) for name, ov in CASES.items()}
    finally:
        shutil.rmtree(scratch, ignore_errors=True)
    json.dump(snap, open(out, "w"), indent=2, sort_keys=True)
    print(f"rendered {len(snap)} cases -> {out}")


main()
