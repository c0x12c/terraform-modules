---
applyTo: ".github/workflows/**/*.yml,.github/workflows/**/*.yaml,**/action.yml,**/action.yaml,.github/scripts/**/*.sh"
---

# GitHub Actions: shell logic lives in script files

When reviewing workflow files, composite actions and CI scripts, flag the following.

## Inline scripts in `run:`

A step's `run:` holds at most a short command list. Flag any `run:` block (`|` or `>`) that:

- has more than 3 command lines, or
- contains shell control flow: `if`, `for`, `while`, `until`, `case`, a function definition, or a heredoc (`<<`).

Ask for the body to move to a script file, called from the step:

```yaml
- name: Validate examples
  env:
    MODULE: ${{ matrix.module }}
  run: .github/scripts/module-ci/check-module-examples.sh "$MODULE"
```

Only flag `run:` blocks the pull request adds or changes. Leave existing inline blocks alone unless the PR edits them.

## Script location and naming

- Workflow scripts: `.github/scripts/<workflow-file-name-without-extension>/<verb>-<noun>.sh`, for example `.github/scripts/deploy-dev/render-argocd-values.sh`.
- Composite action scripts: next to the `action.yml`, called with `${{ github.action_path }}/<verb>-<noun>.sh`.
- Kebab-case, lowercase letters, digits and hyphens only. One script per step. Name it after what it does, not after the step number.

## Script contents

- First line `#!/usr/bin/env bash`, followed by `set -euo pipefail`.
- A header comment: what it does, why it exists, and a `Usage:` line.
- Committed as executable (`git update-index --chmod=+x`).
- Passes `shellcheck` without disables that lack a comment explaining them.
- Takes inputs from environment variables set in the step's `env:` or from arguments. Flag any `${{ ... }}` expression inside a script, or `${{ ... }}` interpolated directly into a `run:` command for untrusted values (PR titles, branch names, issue bodies); that is a script-injection risk. Pass them through `env:` instead.
