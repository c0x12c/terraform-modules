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

1. **MEASURED 2026-08-27. Peak day 26,050 requests; 7-day average 13,836/day.**
   Against the free tier's 100k/day that is 26% of the cap at peak. Not imminent,
   but a 4x busy day reaches it, and the failure at the cap is not graceful: every
   `terraform init` fails at once. Daily figures for 2026-08-19..26 were 16310,
   22107, 14979, 4647, 1768, 7317, 26050, 17511 - note the 15x spread between the
   quietest and busiest day, so an average is the wrong number to plan against.

   Early caching effect: average requests/hour was 605 in the 23 hours before the
   cache deploy and 433 in the 14 hours after, a ~28% drop consistent with removing
   the archive third. Treat as directional only - it is confounded by time-of-day
   and weekday traffic variation, and one day is not a baseline.

   **Plan tier is still UNKNOWN.** The available API token is scoped to Workers and
   R2 and cannot read account subscriptions, so this needs a dashboard check. Do not
   read the absence of a subscription listing as proof of the free tier.
2. **R2 bucket versioning state is UNKNOWN, not confirmed off.** The registry R2
   token has object read/write only, so `GetBucketVersioning` returns AccessDenied.
   Needs a dashboard check. Enabling it remains the cheap half of durability.

   **MEASURED: the entire bucket is 818 objects / 2.9 MB** (`index.json` is 8 KB).
   That is small enough to change the shape of the durability question - a complete
   offsite copy is a 3 MB transfer, not a storage project. Any scheduled job that can
   reach R2 can hold a full snapshot somewhere outside the Cloudflare account.
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
