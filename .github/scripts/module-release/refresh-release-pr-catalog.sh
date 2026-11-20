#!/usr/bin/env bash
set -euo pipefail

[[ ${REPO:-} =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || { echo 'invalid REPO' >&2; exit 1; }
[[ ${RELEASE_BOT:-} =~ ^[A-Za-z0-9-]+\[bot\]$ ]] || { echo 'invalid RELEASE_BOT' >&2; exit 1; }
[[ ${BOT_EMAIL:-} =~ [^[:space:]] && $BOT_EMAIL != *$'\n'* ]] || { echo 'invalid BOT_EMAIL' >&2; exit 1; }
[[ ${GH_TOKEN:-} =~ [^[:space:]] ]] || { echo 'GH_TOKEN is required' >&2; exit 1; }

# Release automation rebuilds each branch from master and drops this commit on
# every run, so rerun after it to land the catalog with the version bump.
refresh() {
  local ref=$1 status push_output
  git fetch origin "$ref" || { echo "$ref: fetch failed"; return 1; }
  git checkout -B "$ref" FETCH_HEAD || { echo "$ref: checkout failed"; return 1; }
  python3 configs/generate_modules_catalog.py || { echo "$ref: generation failed"; return 1; }
  status=$(git status --porcelain -- MODULES.md) || { echo "$ref: status failed"; return 1; }
  if [[ -z $status ]]; then echo "$ref: catalog current"; return 0; fi
  git add MODULES.md || { echo "$ref: staging failed"; return 1; }
  git -c user.name="$RELEASE_BOT" -c user.email="$BOT_EMAIL" commit -m 'chore: regenerate module catalog' || {
    echo "$ref: commit failed"; return 1;
  }
  if push_output=$(git push --porcelain origin "HEAD:$ref" 2>&1); then
    printf '%s\n' "$push_output"
  elif [[ $push_output == *'[rejected]'* ]]; then
    echo "$ref: push rejected, release automation moved the branch"
  else
    echo "$ref: push failed: $push_output"; return 1
  fi
}

prs=$(gh api "repos/$REPO/pulls?state=open&per_page=100" --paginate --slurp)
refs=$(jq -r --arg bot "$RELEASE_BOT" '.[][] | select(.user.login == $bot and (.head.ref | startswith("release-please--"))) | .head.ref' <<< "$prs")
failed=0
while IFS= read -r ref; do
  [[ -n $ref ]] || continue
  refresh "$ref" || failed=1
done <<< "$refs"
exit "$failed"
