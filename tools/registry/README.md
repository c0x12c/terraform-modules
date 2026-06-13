# Self-hosted public registry

A minimal, **fully anonymous** Terraform module registry (`modules.v1`) that
replaces the 115 per-module mirror repos with one Cloudflare Worker + one R2
bucket. The source monorepo stays **private**; only built module tarballs are
public.

> Live at **`terraform.c0x12c.com`**. New releases publish to R2 only; the
> existing mirror repos are frozen (kept public + read-only as the rollback
> path) and retired as consumers cut over.

## Pieces
- `worker.js` — the registry. 3 protocol endpoints + a tarball route. ~60 lines.
- `backfill.py` — one-shot: `git archive` every mirror tag → R2 + `index.json`
  (seeds historical versions so the registry is a superset before cutover).
- `wrangler.toml` — Worker + R2 binding + custom-domain note.

## How consumption works (anonymous)
```hcl
module "rds" {
  source  = "terraform.c0x12c.com/c0x12c/rds/aws"
  version = "~> 0.6"
}
```
Terraform hits `/.well-known/terraform.json` → `/v1/modules/.../versions` →
`/v1/modules/.../<v>/download` (204 + `X-Terraform-Get`) → pulls the tarball.
No tokens, no `.terraformrc` — same UX as registry.terraform.io.

## Deploy (one-time)
1. `wrangler r2 bucket create c0x12c-tf-modules`
2. Set a custom domain on the Worker (`terraform.c0x12c.com`), TLS is automatic.
3. `wrangler deploy`

## Publish (per release)
`registry-publish.yml` runs `scripts/mirror_release.py` for each released
module: it assembles the module from the monorepo, rewrites sibling sources,
runs `terraform validate`, packs the tree, and uploads it to R2 + updates
`index.json`. R2 is the only target — no GitHub mirror repo is touched.

## Cost
- Worker: free tier 100k req/day. R2: 10 GB + Class-A/B ops free tier; **zero egress**.
- Effectively **$0/mo + domain (~$10/yr)**.

## Migration notes
- Run **alongside** the existing mirrors + public registry; cut consumers over
  module-by-module, then retire the mirrors once traffic moves.
- Consumer cost: one-time `source` host change
  (`registry.terraform.io/c0x12c/x/aws` → `terraform.c0x12c.com/c0x12c/x/aws`).
- Module tarballs are packed at archive root (files at top level), so
  `X-Terraform-Get` needs no `//subdir`.

## Verified protocol facts
- Discovery returns `{"modules.v1": "/v1/modules/"}` (relative base allowed).
- `versions` body: `{"modules":[{"versions":[{"version":"x"}]}]}`, 404 if absent.
- `download`: HTTP 204 + `X-Terraform-Get` (accepts an HTTPS tarball URL).
- Protocol defines **no auth** — anonymous is spec-compliant.
