# Registry recovery runbook

For losing the Cloudflare account that hosts the registry. For the narrower case
of losing or corrupting objects while the account is fine, use
[`registry-restore.md`](registry-restore.md) - that is a shorter procedure and
the one you will need far more often.

Nothing here has been rehearsed. See "Rehearsal" at the end; a procedure nobody
has run is a draft, and this one says so rather than implying otherwise.

## What is actually at risk

The Worker, the R2 bucket, and the DNS records all live in one Cloudflare
account. Losing it - billing lapse, compromise, accidental deletion - takes all
three at once, and `terraform init` fails for every project until the registry is
serving again.

**The domain is not at risk.** `c0x12c.com` is registered with Squarespace
Domains II LLC; Cloudflare is only the DNS host (`asa.ns.cloudflare.com`,
`wesley.ns.cloudflare.com`). Control of the domain sits in the registrar account,
so nameservers can be repointed without Cloudflare's cooperation. This is the
fact that makes recovery possible rather than a rebuild from nothing.

**The stats database is not worth recovering.** The Worker degrades gracefully
with no D1 binding - downloads still serve and counts read zero. Do not let it
block a restore.

## Expected RPO and RTO

- **RPO: up to 24 hours.** Snapshots run daily. Any module version published
  between the last snapshot and the loss must be re-released from the monorepo.
- **RTO: hours, dominated by nameserver propagation**, which is not under our
  control. Every step before the NS change can be done in parallel with it.

## Procedure

### 1. Confirm the scope before acting

```
curl -sS -o /dev/null -w '%{http_code}\n' https://terraform.c0x12c.com/healthz
dig +short terraform.c0x12c.com
```

A 5xx with DNS still resolving is a Worker or R2 problem, not account loss - stop
here and use `registry-restore.md`. Only proceed if the account itself is gone.

### 2. Get the most recent snapshot first

Do this before touching DNS; it is the step with a deadline, because artifacts
expire after 30 days.

```
gh run list --workflow registry-snapshot.yml --limit 10
gh run download <run-id> --name registry-snapshot-<date>
```

Check `manifest.json` for `generated_at` and `object_count` before relying on it.

### 3. Stand up a new Cloudflare account

Rebuilding on Cloudflare is faster than moving providers, because the Worker,
the bindings, and the deploy workflow all carry over unchanged. Moving to another
provider means rewriting the Worker, and is only worth it if Cloudflare itself is
the reason you are here.

- Create the account and add the `c0x12c.com` zone. Note the nameservers it gives.
- Recreate the R2 bucket with the **same name** as the binding in
  `tools/registry/wrangler.toml`, or update the binding to match.
- Recreate the DNS records the zone was serving. The zone hosts more than this
  registry, so treat that as its own inventory problem, not an afterthought.

### 4. Repoint nameservers at the registrar

At Squarespace, replace the Cloudflare nameservers with the new ones. This is the
point of no return for the old account and the step that sets the RTO. Start it
as early as you can - the remaining steps do not depend on it finishing.

### 5. Restore the objects

Follow [`registry-restore.md`](registry-restore.md) against the new bucket. Use
the dry run first: it verifies every object against its recorded checksum, so a
damaged artifact fails before a half-finished restore rather than during one.

### 6. Redeploy the Worker

Point the repo at the new account, then dispatch the existing deploy:

```
gh secret set CLOUDFLARE_API_TOKEN
gh secret set CLOUDFLARE_ACCOUNT_ID
gh workflow run registry-deploy.yml
```

`REGISTRY_DEPLOY_ENABLED` must be `true` for the deploy to do anything. Then
attach `terraform.c0x12c.com` to the Worker as a custom domain; TLS is issued
automatically.

### 7. Verify with a real client, not a health check

```
curl -sS https://terraform.c0x12c.com/.well-known/terraform.json
```

then, in a scratch directory, a `terraform init` against a pinned module. The
protocol endpoints can look healthy while a tarball is missing; only a real
client resolving a real version proves the restore.

### 8. Re-publish anything lost to the RPO gap

Compare `index.json` against the monorepo's tags. Any version tagged after the
snapshot needs re-releasing.

## While it is down

Consumers are not stuck. [`registry-outage-fallback.md`](registry-outage-fallback.md)
covers reusing an initialised module cache, switching to a git ref, or vendoring.
Send that link early - it is the difference between every project blocked and
every project inconvenienced.

## Rehearsal

This procedure is unrehearsed, which means its real RTO is a guess.

The cheap rehearsal is step 5 alone: create a throwaway R2 bucket, restore the
latest snapshot into it, and confirm the object count and checksums match the
manifest. That exercises the artifact, the restore tool, and the operator's
familiarity with both, without touching DNS or the live bucket. It needs an R2
credential with bucket-create rights, so it is an owner action.

Doing that once converts the largest unknown here - whether the backup is
actually restorable - from an assumption into a fact.
