# Decision: Collapse the module registry into a monorepo (hybrid, registry-preserving)

Status: **Accepted** · Date: 2026-06-06 · Scope: `terraform-modules` (renamed from `terraform-modules-registry` 2026-06-07)

## Problem

The registry is 116 git submodules (`terraform-aws-*`, `terraform-gcp-*`, `terraform-datadog-*`, …),
each its own GitHub repo with its own CI, Dependabot, GitHub App secret, and `CHANGELOG.md`-driven
release. Maintaining 100+ repos in lockstep is expensive (config-sync tooling, secret fan-out) and
the submodule UX is fragile (orphaned refs have broken CI more than once). We want one repo with a
folder per module — **without** breaking independent per-module semver or existing consumers.

## Constraints (from inventory)

- Modules publish to the **public** HashiCorp registry (`c0x12c` namespace). The public registry maps
  **one repo → one module** with whole-repo `vX.Y.Z` tags. Per-folder versioning is **not** supported.
- Consumers in ~25 internal project repos reference modules in three ways:
  - **839** references via the registry block `source = "c0x12c/<name>/<provider>"` — many with `~>`
    version ranges.
  - **370** references via the prior monorepo `source = "github.com/spartan-stratos/terraform-modules//<subdir>?ref=vX"`.
  - A handful of direct `git::` subdir references.
- `~>` version-range constraints work **only** with registry sources. Git sources (`?ref=tag`) are
  exact pins, no ranges.
- Per-module versions are independent today (e.g. `terraform-aws-rds` v0.6.6, `terraform-aws-eks-cluster`
  v1.0.2), driven by each repo's `CHANGELOG.md` → release workflow → whole-repo tag.
- 33 module `.tf` files reference sibling modules via the registry.

## Options considered

| | End state | Consumer impact | `~>` ranges | New deps | Verdict |
|---|---|---|---|---|---|
| **A** Monorepo + git source, per-folder tags | Cleanest; no registry | Rewrite all 839 + 370 refs | **Lost** | none | Rejected — large one-time migration **and** a permanent regression on version ranges |
| **B** Monorepo + monorepo-aware private registry | Keeps registry UX | Migrate namespaces, re-publish 116 modules | Kept | New registry platform (Spacelift/Scalr/self-hosted) + cost | Rejected — heaviest, adds a paid platform dependency |
| **C** Hybrid: monorepo is source of truth, auto-mirror each folder to its per-module repo on release | Keeps registry + every existing ref | **Zero** consumer migration | Kept | Subtree-split + mirror-push automation | **Accepted** |

## Decision: Option C (hybrid)

The monorepo becomes the single development source of truth. Release CI splits each **changed** module
folder and pushes it to its existing per-module repo, then tags it. The per-module repos become **dumb
automated outputs** — no Dependabot, no per-repo secrets, no human PRs. The public registry and all 839
registry-block references keep working untouched.

Rationale: 839 live references with `~>` ranges make zero-consumer-migration the dominant criterion. The
registry investment already works; the real pain is the 100-repo *config-sync machinery*, which collapses
onto one repo under C. A and B both pay a large migration cost for a worse or more expensive end state.

**Honest cost:** C replaces fragile submodule/sync machinery with *new* subtree-split-and-mirror-push
automation across 100 repos. Our own history (orphaned refs, batch submodule-push failures) is exactly
this failure mode, so the mirror job must be idempotent, retryable, and alarm on partial failure. C also
only partially meets the "remove the repos" goal — the repos persist, but as generated artifacts, not
hand-maintained sources.

## Tag convention

- In-monorepo, per-module tags use a **prefix**: `terraform-aws-rds/v1.2.0`. This lets `release-please`
  (manifest / monorepo mode) version and changelog each folder independently from one repo.
  Note: `release-please`'s default component-tag separator is a hyphen
  (`terraform-aws-rds-v1.2.0`); the slash form requires `tag-separator: "/"` in the manifest config.
- Mirror repos and the registry require **clean** whole-repo tags: `v1.2.0`. The release job maps
  `<module>/vX.Y.Z` (monorepo) → `vX.Y.Z` (mirror) when it pushes the split. **This prefix→clean mapping
  is the load-bearing step** — get it wrong and the registry publishes the wrong version or none.

## History preservation

Squash-import each module folder; do **not** filter-repo the full history of 116 modules into the
monorepo. Per-module history stays browsable in the (now mirror) repos. Cost of a full history merge
(rename collisions, 116 filter-repo runs, a huge initial commit) outweighs its value — the modules' git
history is preserved in the mirrors regardless.

## CI design

- **PR CI (path-filtered):** run `fmt` / `validate` / `tflint` / `docs` only for folders changed in the
  PR. Never run 116-module CI on every PR.
- **Release CI (`module-release.yml`, on merge to `master` after cutover):** `release-please` opens/merges release PRs and creates
  `<module>/vX.Y.Z` tags for changed folders. A follow-on `registry-publish.yml` job, **per changed module only**:
  1. Check out the mirror repo's existing `master`, **copy** the module folder's current contents over it
     (not `git subtree split` — split extracts history verbatim and cannot rewrite file contents, would
     force a force-push that discards the mirror's history, and can't do the sibling-source rewrite below).
  2. Rewrite relative sibling sources back to registry refs (`sed`: `../terraform-<provider>-<name>` →
     `c0x12c/<name>/<provider>`) so the mirror is registry-consumable.
  3. Commit onto the mirror's `master` and push the clean `vX.Y.Z` tag — TFC auto-publishes the new
     version because the mirror keeps its VCS connection (publish is tag-webhook-driven, not script-driven;
     `registry-register.yml` only does the one-time registration).
  4. Idempotent + retryable; alarm on partial failure across modules.

## Consumer & tooling impact

- **Consumers:** no change required. Registry-block refs and old-monorepo refs both keep resolving.
  Optionally publish a one-time codemod later to move `spartan-stratos/terraform-modules//<subdir>` refs
  onto the registry block — independent of this migration.
- **Sibling module deps (33 files):** rewrite `source = "c0x12c/<name>/<provider>"` → relative
  `../terraform-<provider>-<name>` so cross-module changes are atomic and testable in one PR. The mirror
  job must **not** push relative paths to mirrors — mirrors need the registry form, so the copy step
  rewrites relative sibling sources back to registry refs on the way out (see Release CI step 2).
- **Tooling that collapses to one repo config:** the config-sync script, manifest, state file,
  per-repo Dependabot, and per-repo GitHub App secrets. Dependabot runs once on the monorepo; the GitHub
  App secret lives only where release CI runs.

## Follow-up implementation tickets (to be created)

1. Scaffold monorepo `release-please` manifest + per-module config (prefix tags, per-folder changelog).
2. Build path-filtered PR CI (`fmt`/`validate`/`tflint`/`docs` per changed folder).
3. Build the release mirror job (copy folder → relative→registry source rewrite → commit onto mirror
   master → clean `vX.Y.Z` tag map), idempotent + alarmed. **Not** `git subtree split`.
4. Squash-import all module folders into the monorepo; freeze mirror repos to automation-only (strip
   Dependabot, human PRs, branch protections that block the bot). **Preserve each mirror's TFC GitHub App
   VCS connection** — it is the tag-triggered registry publish path; removing it silently breaks publishing.
5. Rewrite the 33 sibling `source` refs to relative paths.
6. Retire the config-sync tooling (script, manifest, state file) once the monorepo config is authoritative.
7. (Optional, independent) codemod consumer `spartan-stratos/terraform-modules//<subdir>` refs onto the
   registry block.
