# Dedicated R2 token for the registry health-check cron

The weekly `registry-health-check` workflow verifies that `index.json` and the R2
bucket agree (List + GET only). It runs with its **own** R2 token, separate from
the credentials `registry-publish` uses to upload tarballs, so the health-check
token can be rotated or revoked independently without disrupting publishing.

> Note: this token is provisioned as **Object Read & Write** by decision. That
> does not reduce permissions versus the publish creds - the health check never
> writes, so a read-only token would be the least-privilege choice - but it does
> give credential **separation** (independent rotation/revocation). To get the
> full blast-radius reduction later, re-create it as **Object Read only**; no
> workflow change is needed, only the token's permission.

## One-time provisioning

1. **Create the R2 token** (Cloudflare dashboard, account `spartan-cf`):
   - R2 -> *Manage R2 API Tokens* -> *Create API token*
   - Permissions: **Object Read & Write**
   - Scope: **Apply to specific buckets only** -> `c0x12c-tf-modules`
   - Create, then copy the generated **Access Key ID** and **Secret Access Key**.
   - (Equivalent API path requires a token with `API Tokens: Edit`; the existing
     R2-scoped automation token cannot mint tokens.)

2. **Add the GitHub repository secrets:**
   - `R2_HEALTHCHECK_ACCESS_KEY_ID`     = the new Access Key ID
   - `R2_HEALTHCHECK_SECRET_ACCESS_KEY` = the new Secret Access Key

   The existing `R2_ENDPOINT` repo secret (the account S3 endpoint URL, not a
   credential) is reused unchanged.

## Ordering (important)

Add both secrets **before** merging the workflow change. The next scheduled run
(Mondays 06:00 UTC) or any `workflow_dispatch` run with the new secrets absent
will fail authentication and open a `registry-health` failure issue.

## Verify

After the secrets exist and the change is merged, trigger the workflow manually
(*Actions -> registry-health-check -> Run workflow*) and confirm it completes
green.
