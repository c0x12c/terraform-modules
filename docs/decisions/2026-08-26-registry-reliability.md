# Registry reliability - what was decided, and what is still open

Status: **Partially accepted** - Date: 2026-08-26 - Scope: `terraform.c0x12c.com`

Follow-on to [`2026-06-08-self-host-registry.md`](2026-06-08-self-host-registry.md),
written after the registry became a dependency of client project applies.

## Framing

There is no server to make redundant. The registry is a stateless Cloudflare Worker
over an R2 bucket, so compute redundancy is Cloudflare's and is not something this
repo can add to. The exposures that scale with adoption are **request budget**,
**detection time**, and **durability**, and those are what the work below addresses.

## What the original ADR assumed that is no longer true

The 2026-06-08 ADR lists as its first mitigation: *"keep the mirrors as hot fallback
through Phase 3 - don't retire until traffic has moved."* Phase 4 has since shipped
and all 115 mirror repos are archived. **The fallback the design depended on no
longer exists.** One Cloudflare account is now the only copy of every module version
consumed by every project.

## Decided and shipped

- **Archive responses are edge-cached** through the Cache API, `max-age=86400` plus
  the R2 ETag. Not `immutable`: `scripts/migrate_r2_source_host.py` can re-upload
  existing version keys, and a year-long TTL would leave no practical purge path.
  Revisit once the historical source-host rewrite is confirmed complete.
- **Cache hits skip the D1 download counter.** Accepted trade: pull stats lose
  cold-fetch fidelity in exchange for the availability win.
- **Transient 503s carry `Retry-After`**; the catch-all 503 deliberately does not,
  because that branch catches code defects and hinting a retry would multiply load
  against an already-broken Worker.
- **An endpoint probe** covers `/healthz`, `/versions`, and the archive route. The
  cron asks for 15 minutes, but GitHub throttles scheduled workflows: measured over
  the first hours after merge the actual interval was 41-79 minutes. Treat the real
  detection window as **roughly an hour**, not 15 minutes. It is best-effort and runs
  inside the same scheduler it monitors, which is the other reason it does not
  substitute for an external check.
- **Consumer fallback options are documented** in
  [`../registry-outage-fallback.md`](../registry-outage-fallback.md).

## Open - needs an owner decision

1. **Workers plan tier and actual requests/day are unmeasured.** A root using N
   modules costs roughly `N * 3` requests per `terraform init`. At the free tier's
   100k/day that is on the order of 1,600 inits/day across all consumers, and the
   failure at the cap is not graceful: every init fails at once. Measure before
   deciding whether the paid tier is needed.
2. **R2 bucket versioning is not enabled.** This is the cheap half of durability and
   closes the accidental-object-loss case outright.
3. **Account-level loss has no recovery path.** The zone, the Worker, and the bucket
   share one Cloudflare account, so account loss takes DNS for the whole domain with
   it. An offsite object copy does not fix this on its own - restoring service would
   require a nameserver migration. Decide explicitly whether account-loss is in
   scope; if it is, the work is registrar-level zone recovery plus a pre-tested NS
   switch, and that is its own project.
4. **There is no SLO and no owner.** Proposed: 99.9% availability on
   `GET /v1/modules/*` measured at an external probe, which is about 43 minutes of
   error budget per month, with burn-rate alerts at 14.4x/1h and 6x/6h. Without an
   agreed number, every future "is this enough?" is a matter of opinion.
5. **No external synthetic check.** The probe above runs on GitHub's scheduler,
   inside the failure domain it monitors. A check from outside Cloudflare is what
   would actually observe a total edge failure.

Items 1 and 2 are cheap and independent. Item 3 is the one that decides whether this
service has a disaster-recovery story at all.
