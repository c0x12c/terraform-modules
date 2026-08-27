"""Warn before the registry Worker reaches its daily request cap.

Workers Free is a hard daily cap rather than a throttle: past it the Worker stops
serving until UTC midnight and every `terraform init` fails at once. The cliff is
invisible until it is hit, so this reads yesterday's count and fails the job while
there is still room to act.

The limit is an argument, not a constant. 100k is the free-tier figure; on a paid
plan the right value is far higher and a hardcoded number would cry wolf daily.
A guard that cries wolf trains the reflex to ignore it.
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request

GRAPHQL_URL = "https://api.cloudflare.com/client/v4/graphql"

QUERY = """
query($acc: String!, $since: Date!, $until: Date!, $script: String!) {
  viewer {
    accounts(filter: {accountTag: $acc}) {
      workersInvocationsAdaptive(
        limit: 100
        filter: {date_geq: $since, date_leq: $until, scriptName: $script}
      ) {
        sum { requests }
        dimensions { date }
      }
    }
  }
}
"""


def classify(requests, limit, warn_pct, fail_pct):
    """Return (state, message). State is one of ok, warn, over.

    Boundaries are inclusive on the way up: hitting the threshold exactly counts
    as reaching it. An off-by-one here is invisible in production because the
    alarm simply never fires.
    """
    if limit <= 0:
        raise ValueError("limit must be positive")
    pct = requests * 100.0 / limit
    detail = "%d requests, %.1f%% of a %d/day limit" % (requests, pct, limit)
    if pct >= fail_pct:
        return "over", "request volume past the alert threshold: %s" % detail
    if pct >= warn_pct:
        return "warn", "request volume approaching the cap: %s" % detail
    return "ok", detail


def parse_response(payload):
    """Pull daily request totals out of a GraphQL response.

    Anything unexpected raises. A quota alarm that reports zero when it cannot
    read the response is worse than no alarm, because it is believed.
    """
    if payload.get("errors"):
        raise SystemExit(
            "GraphQL error - if this mentions permissions, the token needs "
            "Account Analytics Read: %s" % json.dumps(payload["errors"])[:300]
        )
    try:
        accounts = payload["data"]["viewer"]["accounts"]
    except (KeyError, TypeError) as exc:
        raise SystemExit("unexpected GraphQL response shape: %s" % exc)
    if not accounts:
        raise SystemExit("no account matched the supplied account id")
    rows = accounts[0].get("workersInvocationsAdaptive")
    if rows is None:
        raise SystemExit("response contained no workersInvocationsAdaptive block")
    return {r["dimensions"]["date"]: r["sum"]["requests"] for r in rows}


def fetch(account, token, script, since, until):
    body = json.dumps(
        {
            "query": QUERY,
            "variables": {
                "acc": account,
                "since": since,
                "until": until,
                "script": script,
            },
        }
    ).encode("utf-8")
    req = urllib.request.Request(
        GRAPHQL_URL,
        data=body,
        headers={
            "Authorization": "Bearer %s" % token,
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        raise SystemExit("analytics request failed: HTTP %s" % exc.code)
    except urllib.error.URLError as exc:
        raise SystemExit("analytics request failed: %s" % exc.reason)


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument("--account", required=True)
    p.add_argument("--script", required=True)
    p.add_argument("--since", required=True)
    p.add_argument("--until", required=True)
    p.add_argument("--limit", type=int, required=True)
    p.add_argument("--warn-pct", type=float, default=60.0)
    p.add_argument("--fail-pct", type=float, default=85.0)
    p.add_argument("--token-env", default="CLOUDFLARE_API_TOKEN")
    args = p.parse_args(argv)

    import os

    token = os.environ.get(args.token_env)
    if not token:
        raise SystemExit("%s is not set" % args.token_env)

    daily = parse_response(fetch(args.account, token, args.script, args.since, args.until))
    if not daily:
        raise SystemExit("analytics returned no days in the requested window")

    peak_day = max(daily, key=lambda d: daily[d])
    state, message = classify(daily[peak_day], args.limit, args.warn_pct, args.fail_pct)

    for day in sorted(daily):
        print("%s  %d" % (day, daily[day]))
    print("peak day %s: %s" % (peak_day, message))

    return 0 if state == "ok" else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
