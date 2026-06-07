# Terraform Modules Registry

Monorepo for all c0x12c Terraform modules. Each `terraform-<provider>-<name>/`
folder is an independently versioned module published to the
[public Terraform registry](https://registry.terraform.io/namespaces/c0x12c)
under the `c0x12c` namespace.

Consumers reference modules the same way they always have:

```hcl
module "rds" {
  source  = "c0x12c/rds/aws"
  version = "~> 0.6"
}
```

Design background: [docs/decisions/2026-06-06-monorepo-migration.md](docs/decisions/2026-06-06-monorepo-migration.md)
· [release flow diagram](docs/decisions/2026-06-06-monorepo-release-flow.md)

---

## How a change becomes a published version

```mermaid
flowchart LR
  A["1. PR edits<br/>terraform-aws-rds/"] --> B["2. Module CI<br/>(changed folders only)"]
  B --> C["3. Merge to master"]
  C --> D["4. release-please opens<br/>release PR for the module"]
  D --> E["5. Merge release PR<br/>→ tag terraform-aws-rds/v1.2.1"]
  E --> F["6. Registry Publish mirrors folder<br/>→ c0x12c/terraform-aws-rds, tag v1.2.1"]
  F --> G["7. Registry publishes v1.2.1<br/>(webhook, ~30s)"]
```

Steps 1, 3, 5 are the only human actions. Merging the release PR is the
"ship it" decision; everything after is automated and idempotent.

### Worked example — patch a module

1. Branch and edit, using a [conventional commit](https://www.conventionalcommits.org/):

   ```bash
   git checkout -b yourname/rds-backup-window
   # edit terraform-aws-rds/variables.tf
   git commit -m "fix: widen allowed backup_window range"
   ```

2. Open the PR. **Module CI** runs `fmt` / `validate` / `tflint` / docs check
   for `terraform-aws-rds` only — a PR never triggers CI for untouched modules.

3. Merge. **release-please** opens (or updates) a release PR titled
   `chore(master): release terraform-aws-rds 0.6.7` containing the version
   bump and the module's `CHANGELOG.md` entry.

4. Merge the release PR when you want the version shipped. The pipeline then
   tags `terraform-aws-rds/v0.6.7`, mirrors the folder to
   `c0x12c/terraform-aws-rds`, pushes clean tag `v0.6.7`, and the registry
   publishes it. Verify at
   `https://registry.terraform.io/modules/c0x12c/rds/aws`.

### Commit message → version bump

| Commit prefix | Bump (≥ 1.0) | Bump (0.x) |
|---|---|---|
| `fix:` | patch | patch |
| `feat:` | minor | minor |
| `feat!:` / `BREAKING CHANGE:` footer | major | **minor** |
| `chore:`, `docs:`, `ci:`, `refactor:` | no release | no release |

A commit touching a module's files counts toward that module's next version.
Unmerged release PRs accumulate further commits — one version per merge of the
release PR, not per commit.

## Cross-module changes

Edit any number of modules in one PR — review and CI are atomic. On merge,
release-please opens **one release PR per touched module**
(independent versions); ship them all or hold some back.

For sibling dependencies (one module consuming another), in-repo sources use
relative paths so cross-module changes are testable in a single PR:

```hcl
# inside terraform-datadog-gcp-integration/main.tf
module "service_account" {
  source = "../terraform-gcp-service-account"
}
```

At release time the mirror job rewrites this to the registry form with an
**exact pin** of the sibling's currently released version:

```hcl
module "service_account" {
  source  = "c0x12c/service-account/gcp"
  version = "1.0.0"
}
```

Published artifacts are immutable: releasing the sibling later does **not**
retroactively change consumers' pins — each consumer re-pins at its own next
release. For a breaking sibling change, update the sibling and its consumers
in the same PR, then release the sibling first and the consumers after.

## Module CI expectations

Every PR must pass, per changed module:

- `terraform fmt -check -recursive`
- `terraform init -backend=false && terraform validate`
- `tflint` (fails on errors; warnings are reported but non-blocking)
- `terraform-docs` output check, when the module has a `.terraform-docs.yml`

Run locally before pushing:

```bash
cd terraform-aws-rds
terraform fmt -recursive && terraform init -backend=false && terraform validate
tflint
```

**Pin provider upper bounds when a provider release breaks the schema** — a
floating `>= x` constraint can make `validate` fail without any change on our
side (e.g. datadog provider 3.80 made `metric_namespace_configs.filters`
required; fixed with `>= 3.46, < 3.80`).

## Troubleshooting a release

| Symptom | Action |
|---|---|
| Release PR not opened after merge | Commits were `chore:`/`docs:` (no release), or the change didn't touch module files. Check the Module Release workflow run. |
| `mirror-failure` issue opened | A mirror push failed. Read the linked run log, fix the cause, then re-run **Registry Publish** via *Actions → Registry Publish → Run workflow* with the module + version. The job is idempotent — partial failures (e.g. mirror master updated, tag missing) self-heal on re-run. |
| Tag exists on mirror with different content | Never force-push mirror tags. Investigate which content is correct; if the registry already published the bad tag, ship a new patch version instead. |
| Registry didn't publish after mirror tag | Check the mirror repo's TFC GitHub App connection (Settings → GitHub Apps). It must remain installed — it is the publish path. |
| Need a dry-run without a release | *Actions → Registry Publish → Run workflow* with `ref: master`. It exercises clone/rewrite/validate against the real mirror and stops before any conflicting write. |

## Adding a new module

1. Create `terraform-<provider>-<name>/` with standard layout (`main.tf`,
   `variables.tf`, `outputs.tf`, `versions.tf`, `examples/`).
2. Add the module to `module-release-config.json` (`packages`) and seed
   `.module-versions.json` with `"0.0.0"`.
3. Open the PR — Module CI picks the folder up automatically.
4. After the first release tag exists, create the mirror repo
   `c0x12c/terraform-<provider>-<name>` and register it on the public
   registry (one-time, *Actions → Registry Registration*).

## Removing a module

Delete the folder and its `module-release-config.json` /
`.module-versions.json` entries in one PR. Existing published versions
remain available to consumers; the mirror repo can be archived.

## Repository layout

```
terraform-<provider>-<name>/   one folder per module (the only place you edit)
docs/decisions/                architecture decision records
scripts/                       release tooling (mirror_release.py, squash_import.py)
.github/workflows/
  module-ci.yml                PR checks, changed modules only
  module-release.yml           release-please versioning + mirror fan-out
  registry-publish.yml         per-module mirror + tag push (reusable + manual)
  registry-register.yml        one-time registry registration for new modules
```

> **Cutover status:** the monorepo is the source of truth for module code.
> `module-release.yml` is still manually triggered (`workflow_dispatch`) until
> the mirror-freeze step of the migration completes; until then, do not push
> changes directly to the per-module mirror repos — they will be overwritten.
