# Registry recovery runbook

For losing the Cloudflare account that hosts the registry. Losing or corrupting
only some objects while the account is fine uses the same re-publish step (5),
against the existing bucket.

There is no backup of the R2 bucket: the monorepo's `<module>/vX.Y.Z` tags are
the source of truth, and recovery rebuilds every object from them.

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

- **RPO: none for tagged releases.** Every released version is a tag in the
  monorepo and is re-publishable; nothing outside the tags (the stats database,
  see above) is lost that matters.
- **RTO: hours, dominated by nameserver propagation and by re-publishing every
  tag** (one workflow run per version). Every step before the NS change can be
  done in parallel with it.

## Procedure

### 1. Confirm the scope before acting

```
curl -sS -o /dev/null -w '%{http_code}\n' https://terraform.c0x12c.com/healthz
dig +short terraform.c0x12c.com
```

A 5xx with DNS still resolving is a Worker or R2 problem, not account loss - skip
to step 5 and 6 against the existing account. Only run the whole procedure if the
account itself is gone.

### 2. Build the list of versions to re-publish

No snapshot exists, so list the tags while you wait on the account:

```
git fetch --tags && git tag --list '*/v*'
```

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

### 5. Re-publish every version

For each tag from step 2, publish it to the new bucket (`<module>` is the
directory name, the version keeps its `v`):

```
gh workflow run registry-publish.yml -f module=<module> -f version=<vX.Y.Z>
```

Publishing needs the R2 secrets and `R2_BUCKET` pointed at the new bucket first
(step 3). Do one module first and read its run before dispatching the rest.

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

### 8. Check nothing was missed

Compare `index.json` against the monorepo's tags. Any tag absent from the index
needs another step 5 run.

## While it is down

Consumers are not stuck. [`registry-outage-fallback.md`](registry-outage-fallback.md)
covers reusing an initialised module cache, switching to a git ref, or vendoring.
Send that link early - it is the difference between every project blocked and
every project inconvenienced.

## Rehearsal

This procedure is unrehearsed, which means its real RTO is a guess.

The cheap rehearsal is step 5 on one module: create a throwaway R2 bucket, publish
a few tags into it, and confirm the objects and index entries appear. That
exercises the publish path and the operator's familiarity with it without
touching DNS or the live bucket. It needs an R2 credential with bucket-create
rights, so it is an owner action.

It does not tell you how long re-publishing every tag takes, which dominates the
RTO; time it on a sample and scale it.
