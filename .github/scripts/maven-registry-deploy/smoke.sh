#!/usr/bin/env bash
set -euo pipefail
for attempt in 1 2 3 4 5 6; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 10 --max-time 30 "https://$PUBLISH_HOST/healthz" || true)
  printf '%s\n' "$code"
  [ "$code" = 200 ] && exit 0
  if [ "$attempt" -lt 6 ]; then sleep 5; fi
done
exit 1
