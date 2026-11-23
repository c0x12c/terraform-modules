#!/usr/bin/env bash
set -euo pipefail
test -n "${ZONE_ID:-}" || { echo 'ZONE_ID must not be empty' >&2; exit 1; }
buckets=$(npx wrangler@4 r2 bucket list)
if ! grep -Eq "^[[:space:]]*name:[[:space:]]*$BUCKET[[:space:]]*$" <<< "$buckets"; then
  npx wrangler@4 r2 bucket create "$BUCKET"
fi
npx wrangler@4 r2 bucket domain add "$BUCKET" --domain "$READ_HOST" --zone-id "$ZONE_ID" --min-tls 1.2 --force
