# Changelog

All notable changes to this project will be documented in this file.

## [1.4.2]() (2026-05-16)

### Fix Bugs

* `argocd-project` module: force-replace `kubernetes_manifest.this`
  whenever any spec input changes (`sourceRepos`, `destinations`,
  `cluster_resource_whitelist`, `namespace_resource_whitelist`,
  blacklists). Use a sentinel `terraform_data.project_spec_hash`
  with `replace_triggered_by` on the manifest.

  The 1.4.1 fix alone was not enough: when an existing project's
  state was recorded under 1.4.0's broken `ignore_changes` block,
  Terraform's view of "current state" already matches the new
  desired manifest — so plan reports zero diff even after the
  consumer adds new spec fields, and the live AppProject stays
  out-of-sync. `replace_triggered_by` on a hash of the inputs
  guarantees a recreate whenever the consumer changes anything
  that matters.

  Trade-off: a recreate momentarily removes the AppProject (~1 s).
  Child Applications stay in the cluster but ArgoCD will surface
  them as "AppProject not found" until the recreate completes.
  Acceptable for a config-only resource; the alternative is the
  current silent drift, which is worse.

## [1.4.1]() (2026-05-16)

### Fix Bugs

* `argocd-project` module: replace the
  `lifecycle.ignore_changes = [manifest.spec.destinations]` block with
  `field_manager.force_conflicts = true` + a narrow `computed_fields`
  list (annotations, labels, finalizers — the K8s-managed bits that
  legitimately drift). The old `ignore_changes` was suppressing drift
  detection on the entire `manifest` attribute under newer versions
  of the kubernetes provider, so callers who added or updated fields
  like `clusterResourceWhitelist`, `sourceRepos`, etc. saw
  `Apply complete: 0 changed` while the live AppProject stayed
  unchanged — requiring out-of-band `kubectl patch` to recover.

  Force-conflicts on server-side apply preserves the original goal
  (don't fight with K8s defaulting on destinations) while letting
  every other spec field flow through cleanly.

## [1.4.0]() (2026-05-16)

### Features

* `argocd-project` module: add `cluster_resource_whitelist`,
  `namespace_resource_whitelist`, `cluster_resource_blacklist`, and
  `namespace_resource_blacklist` inputs to control which Kubernetes
  resource kinds Applications under the project may sync. Default
  preserves existing behavior (no cluster-scoped resources allowed)
  so this is non-breaking.
* `argocd-project` module: add `source_repos` input (default `["*"]`)
  to override the previously-hardcoded permissive value.

## [1.3.0]() (2026-01-29)

### Features

* Update `trigger.on-deployed`: trigger once per new deployment revision.

## [1.2.2]() (2025-11-20)

### Fix Bugs

* Fix template fallback function check from `try` to `coalesce`.

## [1.2.1]() (2025-11-20)

### Features

* Added variable `notification_templates` to customize notification templates.

## [1.2.0]() (2025-10-24)

### ⚠ BREAKING CHANGES

* Update Helm provider version constraint to v3.

## [1.0.2]() (2025-10-14)

### Features

* Allow custom ingress scheme (for internal ingress)

## [1.0.1]() (2025-06-23)

### Features

* Allow users from different Github Org to login

## [1.0.0]() (2025-06-23)

### Changes

* Update Route53 Module Source to Terraform Registry.

## [0.4.4]() (2025-04-18)

### Fix Bugs

* Fix the in_cluster_name issue

## [0.4.3]() (2025-04-18)

### Features

* Add Route53 record

### Fix Bugs

* Fix the namespace argocd is not found
* Fix the no policy define in the role_policy
* Fix the Ingress annotation to create the ALB listener rules

## [0.4.2]() (2025-04-17)

### Features

* Change variables that defined in `camelCase` to `snake_case`
    * `var.external_cluster`
        * assumeRoles -> assume_role
        * clusterResources -> cluster_resources
        * awsAuthConfig -> aws_auth_config
        * clusterName -> cluster_name
        * roleARN -> role_arn
        * tlsClientConfig -> tls_client_config
        * caData -> ca_data
* Add variable `enabled_managed_in_cluster` to enable in_cluster management, and `in_cluster_name` to change its name
  when `enabled_managed_in_cluster` is enable

## [0.3.15]() (2025-04-11)

### Features

* Add predefined group rules for projects.
* Update destinations for projects and root applications
* Update condition for adding in-cluster and rename it

## [0.3.12]() (2025-04-10)

### Features

* Add annotations for adding new roles

### Fix Bugs

* Fix Github Repository Connection
* Fix projects permission
* Update OIDC arn to OIDC url for cluster connection

### Fix Bugs

* Fix issues relating to yaml format in `tolerations`
* Change `oidc_role_arn` to `oidc_url`
* Fix indent for cluster connections

## [0.3.8]() (2025-04-04)

### Features

* Convert to `yaml` file
* Update Ingress and OIDC Connection
* Add `issuer_url` for dex config

## [0.3.6]() (2025-04-04)

### Features

* Add tolerants which will schedule argocd to managed node

## [0.3.5]() (2025-04-04)

### Fix Bugs

* Remove those attributes when creating helm argocd

```hcl
  wait  = true
timeout = 300
```

## [0.3.3]() (2025-04-03)

### Features

* Update provider version
* Split CRDs include `Projects` and `Applications` to a single sub-module, which will handle creating Projects and
  Applications.

## [0.3.2]() (2025-04-01)

### Features

* Initial commit with all the code
