# AGENTS.md

Rules for any coding agent working in this repository. `CONTRIBUTING.md` is the full contributor
guide and stays authoritative; this file carries the agent-specific rules and the mistakes that keep
recurring here. Read both before the first edit.

## What you may edit

- One module per `terraform-<provider>-<name>/` folder. That folder is the only place module code
  changes.
- `MODULES.md` is generated. Run `python3 configs/generate_modules_catalog.py`; never hand-edit it.
- Adding or removing a module means the disk folder, `module-release-config.json` and
  `.module-versions.json` move together. The `drift` CI job fails when they do not.
- Regenerate module docs with terraform-docs `v0.20.0` after `terraform init -backend=false`.
  A newer binary or a missing lock file fails the check with the same message a genuinely stale
  README produces.

## Generated data must have a staleness check

A snapshot of data that lives somewhere else (an upstream catalog, an API listing, a vendor's
defaults) is a document that goes wrong silently. Do not commit one unless a CI job fails when it
drifts, the way the `MODULES.md` check does. If no such check exists, generate the data on demand
instead of committing it.

## Pull requests

Fill every section of `.github/PULL_REQUEST_TEMPLATE.md`. Do not delete sections; write "none" where
one does not apply.

Read the template file and copy its `##` headings verbatim before you write the body. A body
written from memory is how a free-form description gets merged. The `PR Body` workflow
(`.github/scripts/pr-body/check_pr_body.py`) fails the PR when the body:

- is missing a template section, has them out of order, or leaves one empty
- has no code block under "Verification"
- contains an en-dash, em-dash, AI attribution or a co-author trailer
- runs over 300 words outside code blocks

A red `PR Body` check is fixed by editing the description, not by re-running the job. Never ask for
an admin merge past it. Release-please and Dependabot PRs are exempt because those bodies are
machine-written.

- **State the behaviour after the change, not the investigation that produced it.** No "I first
  tried X, then found Y". A reader wants the result and the reason, not the path.
- **What and why are both mandatory.** A PR that lists files changed without saying why is not
  reviewable.
- **Evidence is a command and its result**, not a claim that something passes. Paste the command and
  the line that proves it.
- **A change to how a module is consumed, or to the release flow, carries a Mermaid diagram** showing
  before and after. Not for internal refactors, test-only changes or signature tidying.
- **A reviewer should get through the whole body in under a minute.** If it runs longer, the surplus
  is either duplication or belongs in a code comment where the change is.
- **No AI attribution anywhere**: not in the PR title, the body, review comments, or commit
  messages. No co-author trailers, no "generated with" lines.
- **Write like an engineer.** Plain sentences. No marketing adjectives, no em-dashes, no symmetrical
  "not just X, but Y" phrasing. Specific numbers and names beat "several" and "various".

Commit messages follow Conventional Commits, because release automation derives the version bump
from the prefix. `CONTRIBUTING.md` has the prefix table.

## Reviews posted to a PR

The review body carries the verdict and only the findings that have no line to attach to. Every
other finding is an inline comment on the line it is about. Do not restate an inline finding in the
body, and do not add a "what I verified" section unless a number in it changes the verdict.
