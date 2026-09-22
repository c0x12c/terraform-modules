#!/usr/bin/env bash
# Validate every examples/*/ directory of one module.
#
# The module root validating says nothing about examples/, which consumers copy first, so an input
# change that breaks or outdates an example is caught here. A module with no examples only warns:
# modules predating the rule should not block an unrelated fix on writing a first example.
#
# Usage: .github/scripts/module-ci/check-module-examples.sh <module-dir>
set -euo pipefail

module="${1:?usage: $0 <module-dir>}"

shopt -s nullglob
examples=("$module"/examples/*/)
if [ ${#examples[@]} -eq 0 ]; then
  echo "::warning title=examples::$module has no examples/ directory. CONTRIBUTING.md requires at least one runnable example."
  exit 0
fi

status=0
for dir in "${examples[@]}"; do
  echo "::group::$dir"
  if ! terraform -chdir="$dir" init -backend=false -input=false || ! terraform -chdir="$dir" validate -no-color; then
    echo "::error title=examples::$dir does not validate."
    status=1
  fi
  echo "::endgroup::"
done
exit $status
