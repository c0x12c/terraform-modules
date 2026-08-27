# Registry SLO and alert routing

Status: **Proposed - needs an owner decision** - Date: 2026-08-27 - Scope: `terraform.c0x12c.com`

Two blanks in this document can only be filled by a person. It is written so that
filling them is a five-minute decision rather than a design exercise.

## The problem this solves

The registry now has more detection than it has ever had - an uptime probe, a
quota watch, a daily snapshot, two CI suites. **None of it reaches a human.**
Every one of those signals terminates in a GitHub Actions run or an issue. If the
registry fails at 02:00, the first person to know is whoever next runs
`terraform init` and reads the error.

Separately, there is no availability target, which means every reliability
question - is caching enough, is the free tier enough, is an external synthetic
worth it - gets answered by opinion, including by whoever is advising.

## Proposal

**SLI:** the proportion of successful responses to `GET /v1/modules/*`, measured
from outside Cloudflare.

**SLO:** 99.9% over a rolling 28 days. That is an error budget of roughly
**43 minutes per month**. Picked because module resolution is on the critical
path of every deploy in every project, and because 99.95% would demand
multi-provider failover that the traffic does not justify - measured peak is
26,050 requests/day.

**Burn-rate alerts** (from the Google SRE workbook's multi-window scheme):

| Burn rate | Window | Budget consumed | Action |
|---|---|---|---|
| 14.4x | 1h | 2% | page |
| 6x | 6h | 5% | page |
| 1x | 3d | 10% | ticket |

**Error-budget policy:** if a single incident burns more than 20% of the month's
budget, it gets a written postmortem. If the budget is exhausted, registry
changes other than fixes and security work pause until the window rolls.

## The two blanks

1. **Who carries this?** A named person, not a team alias. Detection that routes
   to a rota nobody is on is the state we are already in.
2. **Where does a page go?** A destination that wakes someone - phone or SMS, not
   a channel and not a GitHub issue. Once it exists as a repo secret, the existing
   probe and quota watch can post to it; neither needs redesigning.

## What is already in place

- Uptime probe covering `/healthz`, `/versions`, and the archive route. Measured
  cadence is 41-79 minutes rather than the 15 the cron requests, because GitHub
  throttles scheduled workflows.
- Quota watch reading daily request volume, red past a configurable share of the
  daily limit.
- Daily offsite snapshot with a documented restore path.

## What is missing after those blanks are filled

An external synthetic. The existing probe runs on GitHub, which is genuinely a
different provider from Cloudflare, so it would see a total edge failure - the gap
is cadence and paging, not failure-domain independence. A hosted check gives
1-minute cadence and a real phone alert; free tiers cover this volume. Worth doing
only once there is someone to wake.

## Deliberately not proposed

A latency objective. The Worker is stateless and edge-cached, latency has not been
a reported problem, and an SLO nobody is missing is a number that only creates
work.
