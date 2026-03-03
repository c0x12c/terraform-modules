#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$SCRIPT_DIR/manifest.json"
STATE_FILE="$SCRIPT_DIR/state.yaml"

# Defaults
MODE="status"
FILTER_MODULE=""
FILTER_FEATURE=""
FORCE=false
DRY_RUN=false
VERBOSE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[FAIL]${NC} $*"; }

# ---- State File Helpers ----

init_state_file() {
  if [ ! -f "$STATE_FILE" ]; then
    cat > "$STATE_FILE" << 'YAML'
version: 1
last_updated: ""
modules: {}
YAML
  fi
}

write_state() {
  local module="$1" feature="$2"

  # Initialize module with empty features list if needed
  yq -i ".modules[\"$module\"] //= {applied_features: []}" "$STATE_FILE"

  # Add feature to applied_features list if not already present
  yq -i ".modules[\"$module\"].applied_features |= if any(. == \"$feature\") then . else . + [\"$feature\"] end" "$STATE_FILE"
}

read_state() {
  yq -r "$1" "$STATE_FILE" 2>/dev/null
}

record_action() {
  local module="$1" feature="$2"
  write_state "$module" "$feature"
}

is_action_applied() {
  local module="$1" feature="$2"
  local result
  result=$(read_state ".modules.\"$module\".applied_features | any(. == \"$feature\")")
  [ "$result" = "true" ]
}

# ---- Manifest Helpers ----

get_org() {
  jq -r '.org' "$MANIFEST"
}

get_default_branch() {
  jq -r '.default_branch' "$MANIFEST"
}

list_features() {
  jq -r '.features | keys[]' "$MANIFEST"
}

get_feature_description() {
  jq -r '.features["'"$1"'"].description' "$MANIFEST"
}

list_feature_actions() {
  jq -c '.features["'"$1"'"].actions[]' "$MANIFEST"
}

is_module_excluded() {
  local module="$1" feature="$2"
  local excluded
  excluded=$(jq -r '.exclusions["'"$feature"'"] // [] | index("'"$module"'") // empty' "$MANIFEST")
  [ -n "$excluded" ]
}

# ---- Submodule Helpers ----

list_submodules() {
  cd "$REPO_ROOT"
  git submodule status 2>/dev/null | grep -v '^-' | awk '{gsub(/^\+/,"",$1); print $2}'
}

get_repo_name() {
  local module="$1"
  local org
  org=$(get_org)
  echo "${org}/${module}"
}

# Ensure module exists in state
ensure_module_state() {
  local module="$1"
  local exists
  exists=$(read_state ".modules.\"$module\"")
  if [ -z "$exists" ] || [ "$exists" = "null" ]; then
    yq -i ".modules[\"$module\"] = {applied_features: []}" "$STATE_FILE"
  fi
}

# ---- Hash Helpers ----

compute_hash() {
  local file="$1"
  shasum -a 256 "$file" 2>/dev/null | awk '{print "sha256:" $1}'
}

# ---- Action Key Builders ----

action_key_for() {
  local action_json="$1"
  local atype
  atype=$(echo "$action_json" | jq -r '.type')
  case "$atype" in
    file_sync)
      local dest
      dest=$(echo "$action_json" | jq -r '.dest')
      echo "file_sync:${dest}"
      ;;
    secret)
      local name app
      name=$(echo "$action_json" | jq -r '.name')
      app=$(echo "$action_json" | jq -r '.app // "actions"')
      echo "secret:${name}:${app}"
      ;;
    variable)
      local name
      name=$(echo "$action_json" | jq -r '.name')
      echo "variable:${name}"
      ;;
  esac
}

# ---- Action Executors ----

apply_file_sync() {
  local repo="$1" source="$2" dest="$3" commit_msg="$4" branch="$5"
  local source_path="${REPO_ROOT}/${source}"

  if [ ! -f "$source_path" ]; then
    log_error "Source file not found: $source_path"
    return 1
  fi

  local content
  content=$(base64 < "$source_path")

  # Check if file already exists (need SHA for update)
  local existing_sha
  existing_sha=$(gh api "repos/${repo}/contents/${dest}" --jq '.sha' 2>/dev/null || echo "")

  local api_args=(
    --method PUT
    "repos/${repo}/contents/${dest}"
    -f "message=${commit_msg}"
    -f "content=${content}"
    -f "branch=${branch}"
  )

  if [ -n "$existing_sha" ]; then
    api_args+=(-f "sha=${existing_sha}")
  fi

  gh api "${api_args[@]}" --silent 2>/dev/null
}

apply_secret() {
  local repo="$1" name="$2" source_file="$3" app="$4"
  local source_path="${REPO_ROOT}/${source_file}"

  if [ ! -f "$source_path" ]; then
    log_error "Secret source file not found: $source_path"
    return 1
  fi

  local app_flag=""
  if [ "$app" != "actions" ]; then
    app_flag="--app ${app}"
  fi

  gh secret set "$name" --repo "$repo" $app_flag < "$source_path" 2>/dev/null
}

apply_variable() {
  local repo="$1" name="$2" value="$3"
  gh variable set "$name" --repo "$repo" --body "$value" 2>/dev/null
}

# ---- Verify Executors ----

verify_file_sync() {
  local repo="$1" dest="$2"
  gh api "repos/${repo}/contents/${dest}" --jq '.sha' 2>/dev/null
}

verify_secret() {
  local repo="$1" name="$2" app="$3"
  local app_flag=""
  if [ "$app" != "actions" ]; then
    app_flag="--app ${app}"
  fi
  gh secret list --repo "$repo" $app_flag 2>/dev/null | grep -q "^${name}[[:space:]]"
}

verify_variable() {
  local repo="$1" name="$2"
  gh variable list --repo "$repo" 2>/dev/null | grep -q "^${name}[[:space:]]"
}

# ---- Mode: Status ----

do_status() {
  init_state_file

  local submodules
  submodules=$(list_submodules)
  local features
  features=$(list_features)

  # Collect counts per feature
  declare -A applied_count missing_count excluded_count

  for feature in $features; do
    applied_count[$feature]=0
    missing_count[$feature]=0
    excluded_count[$feature]=0
  done

  local missing_details=()

  while IFS= read -r module; do
    [ -z "$module" ] && continue

    if [ -n "$FILTER_MODULE" ] && [ "$module" != "$FILTER_MODULE" ]; then
      continue
    fi

    local module_missing=()

    for feature in $features; do
      if is_module_excluded "$module" "$feature"; then
        excluded_count[$feature]=$(( ${excluded_count[$feature]} + 1 ))
        continue
      fi

      if [ -n "$FILTER_FEATURE" ] && [ "$feature" != "$FILTER_FEATURE" ]; then
        continue
      fi

      local all_applied=true

      while IFS= read -r action_json; do
        local akey
        akey=$(action_key_for "$action_json")

        if is_action_applied "$module" "$feature"; then
          # Feature is applied
          true
        else
          all_applied=false
        fi
      done < <(list_feature_actions "$feature")

      if $all_applied; then
        applied_count[$feature]=$(( ${applied_count[$feature]} + 1 ))
      else
        missing_count[$feature]=$(( ${missing_count[$feature]} + 1 ))
        if $VERBOSE; then
          module_missing+=("  ${RED}$feature${NC} [MISSING]")
        fi
      fi
    done

    if $VERBOSE && [ ${#module_missing[@]} -gt 0 ]; then
      missing_details+=("$module:")
      for line in "${module_missing[@]}"; do
        missing_details+=("$line")
      done
    fi
  done <<< "$submodules"

  # Print summary table
  echo ""
  printf "%-30s %10s %10s %10s\n" "Feature" "Applied" "Missing" "Excluded"
  printf "%-30s %10s %10s %10s\n" "-------" "-------" "-------" "--------"
  for feature in $features; do
    if [ -n "$FILTER_FEATURE" ] && [ "$feature" != "$FILTER_FEATURE" ]; then
      continue
    fi
    printf "%-30s %10d %10d %10d\n" \
      "$feature" \
      "${applied_count[$feature]}" \
      "${missing_count[$feature]}" \
      "${excluded_count[$feature]}"
  done
  echo ""

  if $VERBOSE && [ ${#missing_details[@]} -gt 0 ]; then
    echo "Details:"
    for line in "${missing_details[@]}"; do
      echo -e "$line"
    done
    echo ""
  fi
}

# ---- Mode: Apply ----

do_apply() {
  init_state_file

  local org branch
  org=$(get_org)
  branch=$(get_default_branch)

  local submodules
  submodules=$(list_submodules)
  local features
  features=$(list_features)

  local applied=0 skipped=0 failed=0
  local failures=()

  while IFS= read -r module; do
    [ -z "$module" ] && continue

    if [ -n "$FILTER_MODULE" ] && [ "$module" != "$FILTER_MODULE" ]; then
      continue
    fi

    local repo
    repo=$(get_repo_name "$module")

    for feature in $features; do
      if is_module_excluded "$module" "$feature"; then
        continue
      fi

      if [ -n "$FILTER_FEATURE" ] && [ "$feature" != "$FILTER_FEATURE" ]; then
        continue
      fi

      while IFS= read -r action_json; do
        local akey atype
        akey=$(action_key_for "$action_json")
        atype=$(echo "$action_json" | jq -r '.type')

        # Skip if already applied and not forced
        if ! $FORCE && is_action_applied "$module" "$feature"; then
          skipped=$((skipped + 1))
          continue
        fi

        if $DRY_RUN; then
          log_info "[DRY-RUN] Would apply: $module / $akey"
          applied=$((applied + 1))
          continue
        fi

        ensure_module_state "$module"

        case "$atype" in
          file_sync)
            local source dest commit_msg
            source=$(echo "$action_json" | jq -r '.source')
            dest=$(echo "$action_json" | jq -r '.dest')
            commit_msg=$(echo "$action_json" | jq -r '.commit_message')

            if apply_file_sync "$repo" "$source" "$dest" "$commit_msg" "$branch"; then
              record_action "$module" "$feature"
              log_success "$module / $akey"
              applied=$((applied + 1))
            else
              log_error "$module / $akey"
              failures+=("$module: $akey")
              failed=$((failed + 1))
            fi
            ;;
          secret)
            local name source_file app
            name=$(echo "$action_json" | jq -r '.name')
            source_file=$(echo "$action_json" | jq -r '.source_file')
            app=$(echo "$action_json" | jq -r '.app // "actions"')

            if apply_secret "$repo" "$name" "$source_file" "$app"; then
              record_action "$module" "$feature"
              log_success "$module / $akey"
              applied=$((applied + 1))
            else
              log_error "$module / $akey"
              failures+=("$module: $akey")
              failed=$((failed + 1))
            fi
            ;;
          variable)
            local name value_env value
            name=$(echo "$action_json" | jq -r '.name')
            value_env=$(echo "$action_json" | jq -r '.value_env // empty')
            value=$(echo "$action_json" | jq -r '.value // empty')

            if [ -n "$value_env" ]; then
              value="${!value_env:-}"
              if [ -z "$value" ]; then
                log_error "$module / $akey: env var $value_env is not set"
                failures+=("$module: $akey (env var missing)")
                failed=$((failed + 1))
                continue
              fi
            fi

            if apply_variable "$repo" "$name" "$value"; then
              record_action "$module" "$feature"
              log_success "$module / $akey"
              applied=$((applied + 1))
            else
              log_error "$module / $akey"
              failures+=("$module: $akey")
              failed=$((failed + 1))
            fi
            ;;
        esac
      done < <(list_feature_actions "$feature")
    done
  done <<< "$submodules"

  echo ""
  echo "========================================="
  echo "APPLY SUMMARY"
  echo "========================================="
  echo "  Applied: $applied"
  echo "  Skipped: $skipped (already applied)"
  echo "  Failed:  $failed"
  if [ ${#failures[@]} -gt 0 ]; then
    echo ""
    echo "Failures:"
    for f in "${failures[@]}"; do
      echo "  - $f"
    done
  fi
  echo ""
}

# ---- Mode: Verify ----

do_verify() {
  init_state_file

  local submodules
  submodules=$(list_submodules)
  local features
  features=$(list_features)

  local in_sync=0 drifted=0 missing=0 verified=0
  local drift_details=()

  while IFS= read -r module; do
    [ -z "$module" ] && continue

    if [ -n "$FILTER_MODULE" ] && [ "$module" != "$FILTER_MODULE" ]; then
      continue
    fi

    local repo
    repo=$(get_repo_name "$module")

    ensure_module_state "$module"

    for feature in $features; do
      if is_module_excluded "$module" "$feature"; then
        continue
      fi

      if [ -n "$FILTER_FEATURE" ] && [ "$feature" != "$FILTER_FEATURE" ]; then
        continue
      fi

      while IFS= read -r action_json; do
        local akey atype
        akey=$(action_key_for "$action_json")
        atype=$(echo "$action_json" | jq -r '.type')
        verified=$((verified + 1))

        case "$atype" in
          file_sync)
            local dest
            dest=$(echo "$action_json" | jq -r '.dest')
            local remote_sha
            remote_sha=$(verify_file_sync "$repo" "$dest")

            if [ -n "$remote_sha" ]; then
              # File exists in repo - record as applied
              record_action "$module" "$feature"
              in_sync=$((in_sync + 1))
              if $VERBOSE; then
                log_success "$module / $akey"
              fi
            else
              missing=$((missing + 1))
              drift_details+=("$module: $akey [MISSING in repo]")
              if $VERBOSE; then
                log_warn "$module / $akey [MISSING]"
              fi
            fi
            ;;
          secret)
            local name app
            name=$(echo "$action_json" | jq -r '.name')
            app=$(echo "$action_json" | jq -r '.app // "actions"')

            if verify_secret "$repo" "$name" "$app"; then
              record_action "$module" "$feature"
              in_sync=$((in_sync + 1))
              if $VERBOSE; then
                log_success "$module / $akey"
              fi
            else
              missing=$((missing + 1))
              drift_details+=("$module: $akey [MISSING]")
              if $VERBOSE; then
                log_warn "$module / $akey [MISSING]"
              fi
            fi
            ;;
          variable)
            local name
            name=$(echo "$action_json" | jq -r '.name')

            if verify_variable "$repo" "$name"; then
              record_action "$module" "$feature"
              in_sync=$((in_sync + 1))
              if $VERBOSE; then
                log_success "$module / $akey"
              fi
            else
              missing=$((missing + 1))
              drift_details+=("$module: $akey [MISSING]")
              if $VERBOSE; then
                log_warn "$module / $akey [MISSING]"
              fi
            fi
            ;;
        esac
      done < <(list_feature_actions "$feature")
    done
  done <<< "$submodules"

  echo ""
  echo "========================================="
  echo "VERIFY SUMMARY"
  echo "========================================="
  echo "  Verified: $verified"
  echo "  In sync:  $in_sync"
  echo "  Missing:  $missing"
  echo "  Drifted:  $drifted"
  if [ ${#drift_details[@]} -gt 0 ]; then
    echo ""
    echo "Issues:"
    for d in "${drift_details[@]}"; do
      echo "  - $d"
    done
  fi
  echo ""
  log_info "State file updated: $STATE_FILE"
}

# ---- CLI ----

usage() {
  cat <<'EOF'
Usage: sync-configs.sh [MODE] [OPTIONS]

Modes:
  --status      Show applied/missing/stale configs (default, no API calls)
  --verify      Live check via GitHub API, reconcile state
  --apply       Apply missing configs, update state

Options:
  --module NAME     Filter to a specific submodule
  --feature NAME    Filter to a specific feature
  --force           Re-apply even if already applied
  --dry-run         Show what would be done without executing
  --verbose         Show per-module details
  -h, --help        Show this help

Examples:
  ./sync-configs.sh                              # Quick status check
  ./sync-configs.sh --status --verbose            # Detailed status
  ./sync-configs.sh --apply --module terraform-aws-new-thing  # Apply to new submodule
  ./sync-configs.sh --apply --feature gh-app-secret           # Roll out a feature
  ./sync-configs.sh --apply --force --feature dependabot-automerge  # Re-push updated file
  ./sync-configs.sh --apply --dry-run             # Preview what would change
  ./sync-configs.sh --verify                      # Live check all repos
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --status)   MODE="status"; shift ;;
      --verify)   MODE="verify"; shift ;;
      --apply)    MODE="apply"; shift ;;
      --module)   FILTER_MODULE="$2"; shift 2 ;;
      --feature)  FILTER_FEATURE="$2"; shift 2 ;;
      --force)    FORCE=true; shift ;;
      --dry-run)  DRY_RUN=true; shift ;;
      --verbose)  VERBOSE=true; shift ;;
      -h|--help)  usage; exit 0 ;;
      *)          log_error "Unknown option: $1"; usage; exit 1 ;;
    esac
  done
}

main() {
  parse_args "$@"

  if [ ! -f "$MANIFEST" ]; then
    log_error "Manifest not found: $MANIFEST"
    exit 1
  fi

  case "$MODE" in
    status) do_status ;;
    verify) do_verify ;;
    apply)  do_apply ;;
  esac
}

main "$@"
