#!/usr/bin/env bash
# Merge dependency manifests and release PRs verified by CI at the exact head.
set -euo pipefail

bad_input() { echo "Invalid input: $*" >&2; exit 2; }
release_module() {
  [[ $1 =~ ^release-please--branches--[^-]+--components--(terraform-[a-z0-9-]+)$ ]] || return 1
  printf '%s\n' "${BASH_REMATCH[1]}"
}
release_path() {
  [[ $1 == .module-versions.json || $1 == MODULES.md || $1 == "$2/CHANGELOG.md" || $1 == "$2/README.md" ]]
}
if [[ ${1:-} == --explain-release ]]; then
  [[ $# -ge 2 ]] || bad_input 'bad_input: release ref required'
  module=$(release_module "$2") || bad_input 'bad_input: invalid release ref'
  shift 2
  for path in "$@"; do
    if release_path "$path" "$module"; then echo "$path: ALLOWED"; else echo "$path: DENIED"; fi
  done
  exit 0
fi
[[ -n ${PR_GATES:-} ]] || bad_input 'PR_GATES is required'
workflows=() roots=()
while IFS= read -r line; do
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [[ -n $line ]] || continue
  [[ $line =~ ^([^\|]+)\|([^\|]+)$ ]] || bad_input 'each gate needs two non-empty fields'
  workflow=${BASH_REMATCH[1]} prefixes=${BASH_REMATCH[2]}
  [[ $workflow =~ [^[:space:]] ]] || bad_input 'empty gate field'
  [[ $prefixes != ,* && $prefixes != *, && $prefixes != *,,* ]] || bad_input 'empty prefix'
  IFS=, read -r -a parts <<< "$prefixes"
  for prefix in "${parts[@]}"; do
    [[ $prefix == */ && $prefix =~ [^[:space:]/] ]] || bad_input 'prefixes must end in /'
  done
  workflows+=("$workflow") roots+=("$prefixes")
done <<< "$PR_GATES"
[[ ${#workflows[@]} -gt 0 ]] || bad_input 'PR_GATES must contain at least one gate'

covers() {
  local path=$1 prefixes=$2 prefix
  local parts=()
  IFS=, read -r -a parts <<< "$prefixes"
  for prefix in "${parts[@]}"; do
    [[ $path == "$prefix"* ]] && return 0
  done
  return 1
}
if [[ ${1:-} == --explain ]]; then
  shift
  for path in "$@"; do
    if [[ ${path##*/} != requirements*.txt ]]; then
      echo "$path: NON-MANIFEST"
      continue
    fi
    covered=false
    for i in "${!workflows[@]}"; do
      if covers "$path" "${roots[$i]}"; then
        echo "$path: ${workflows[$i]}"
        covered=true
      fi
    done
    $covered || echo "$path: UNCOVERED"
  done
  exit 0
fi
[[ $# == 0 ]] || bad_input 'unknown arguments'
[[ ${REPO:-} =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || bad_input 'REPO must be owner/name'
[[ ${GH_TOKEN:-} =~ [^[:space:]] ]] || bad_input 'GH_TOKEN is required'

base=$(gh api "repos/$REPO" --jq .default_branch)

run_conclusion() {
  jq -r --arg name "$1" --arg sha "$2" \
    '[.[].workflow_runs[] | select(.name == $name and .head_sha == $sha and .event == "pull_request")] | sort_by(.created_at, .id) | last | .conclusion // "none"' <<< "$3"
}
merge_pr() {
  local number=$1 sha=$2 merge_error
  if [[ ${DRY_RUN:-0} == 1 ]]; then
    echo 'would merge (DRY_RUN)'
  # The App bypasses the approval ruleset; this script enforces the CI gate.
  elif merge_error=$(gh pr merge "$number" --repo "$REPO" --squash --delete-branch --admin --match-head-commit "$sha" 2>&1); then
    echo 'merged'
  else
    echo "merge refused: ${merge_error%%$'\n'*}"
  fi
}

check_pr() {
  local number=$1 sha=$2 kind=$3 ref=$4 files path i found commit message text versions behind runs conclusion authors module bot
  local required=()
  bot='dependabot[bot]'
  if [[ $kind == release ]]; then
    module=$(release_module "$ref") || { echo 'invalid release ref'; return; }
    bot=$RELEASE_BOT
  fi
  if ! files=$(gh api "repos/$REPO/pulls/$number/files?per_page=100" --paginate \
    --jq '.[] | .filename, (.previous_filename // empty)'); then
    echo 'could not list files'; return
  fi
  [[ -n $files ]] || { echo 'zero covered paths'; return; }
  while IFS= read -r path; do
    if [[ $kind == release ]]; then
      release_path "$path" "$module" || { echo "non-release path $path"; return; }
      continue
    fi
    if [[ ${path##*/} != requirements*.txt ]]; then
      echo "non-manifest path $path"; return
    fi
    found=false
    for i in "${!workflows[@]}"; do
      if covers "$path" "${roots[$i]}"; then required[i]=1; found=true; fi
    done
    if ! $found; then echo "uncovered path $path"; return; fi
  done <<< "$files"

  if ! authors=$(gh api "repos/$REPO/pulls/$number/commits?per_page=100" --paginate --slurp); then
    echo 'could not list commits'; return
  fi
  if ! jq -e --arg bot "$bot" 'length > 0 and (map(length) | add) > 0 and all(.[][]; .author.login == $bot)' <<< "$authors" >/dev/null; then
    if [[ $kind == release ]]; then echo 'non-release-bot commit'; else echo 'non-dependabot commit'; fi
    return
  fi
  if [[ $kind != release ]]; then
  if ! commit=$(gh api "repos/$REPO/commits/$sha"); then echo 'could not read commit'; return; fi
  message=$(jq -r '.commit.message' <<< "$commit")
  if grep -q 'update-type: version-update:semver-major' <<< "$message"; then
    echo 'semver-major'; return
  fi
  if ! text=$(gh api "repos/$REPO/pulls/$number" --jq '[.title, .body // ""] | join("\n")'); then
    echo 'could not read versions'; return
  fi
  # Parse only the title and Dependabot summary lines, excluding release notes.
  versions=$(printf '%s' "$text" | python3 "$(dirname "${BASH_SOURCE[0]}")/classify_versions.py")
  [[ $versions == non-major ]] || { echo "$versions"; return; }
  fi
  if ! behind=$(gh api "repos/$REPO/compare/$base...$sha" --jq .behind_by); then
    echo 'could not compare base'; return
  fi
  if [[ $behind != 0 ]]; then
    if [[ $kind == release ]]; then echo "$behind commits behind; waiting for release automation"; return; fi
    if [[ ${DRY_RUN:-0} != 1 ]]; then
      if ! gh pr comment "$number" --repo "$REPO" --body '@dependabot rebase' >/dev/null 2>&1; then
        echo "$behind commits behind; rebase request failed"; return
      fi
    fi
    echo "$behind commits behind; needs rebase"; return
  fi
  if ! runs=$(gh api "repos/$REPO/actions/runs?head_sha=$sha&event=pull_request&per_page=100" --paginate --slurp); then
    echo 'could not read workflow runs'; return
  fi
  if [[ $kind == release ]]; then
    conclusion=$(run_conclusion "$RELEASE_GATE" "$sha" "$runs")
    if [[ $conclusion != success ]]; then echo "$RELEASE_GATE: $conclusion"; return; fi
  fi
  for i in "${!required[@]}"; do
    conclusion=$(run_conclusion "${workflows[$i]}" "$sha" "$runs")
    if [[ $conclusion != success ]]; then echo "${workflows[$i]}: $conclusion"; return; fi
  done
  merge_pr "$number" "$sha"
}

# Paginate the REST listing rather than silently limiting the number of open PRs.
gh api "repos/$REPO/pulls?state=open&per_page=100" --paginate --slurp |
jq -r --arg bot "${RELEASE_BOT:-}" --arg gate "${RELEASE_GATE:-}" '
  .[][] | if .user.login == "dependabot[bot]" then
    "\(.number) \(.head.sha) dependabot \(.head.ref)"
  elif $bot != "" and $gate != "" and .user.login == $bot
    and (.head.ref | test("^release-please--branches--[^-]+--components--(terraform-[a-z0-9-]+)$")) then
    "\(.number) \(.head.sha) release \(.head.ref)"
  else empty end' |
while read -r number sha kind ref; do
  reason=$(check_pr "$number" "$sha" "$kind" "$ref")
  echo "PR #$number (${sha:0:7}): $reason"
done
