# Upgrading terraform-aws-helm-argocd

## 2.0.0

2.0.0 moves the default chart from `7.8.26` (Argo CD v2.14.10, end of life since 2025-11-04) to
`10.19.1` (Argo CD v3.6.3). Argo CD keeps its state in Application and AppProject resources, so the
controllers can move from 2.14 to 3.6 in one apply, but read every upstream guide on the way first:
[upgrading overview](https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/overview/).

### Pinned to the 2.x behaviour

Two chart defaults changed in that range, and the module pins the 2.x behaviour for both:

- `resource_tracking_method` defaults to `label`. Argo CD 3.0 switched to `annotation`. Flip it
  after the upgrade, in its own apply. Live resources do not carry the tracking annotation yet, so
  every application goes OutOfSync on the flip. Applications with auto-sync re-apply every resource
  straight away, which adds the annotation without restarting pods. The others stay OutOfSync until
  someone syncs them; sync them before deleting any resource from Git, because a resource removed
  first never gets the annotation and is left behind instead of pruned.
- `network_policy_enabled` defaults to `false`. Chart 10.0 started creating six NetworkPolicies by
  default.

### What changes on apply

- Every Argo CD pod restarts once. Redis (now 8.x) starts empty, so the controller re-renders every
  application on start; size the controller for that peak. With single replicas the UI and API are
  unavailable while pods roll - set `server.replicas`, `repoServer.replicas`, their `pdb` values and
  a short `lifecycle.preStop` sleep through `extra_values` in an earlier apply to make the upgrade
  rolling.
- The chart adds a headless Service for the application controller and drops the notifications
  controller's ClusterRole and ClusterRoleBinding.
- Redis is pulled from `ecr-public.aws.com`; allow egress to it where egress is restricted.

### Upstream 3.x defaults kept

`update` and `delete` no longer cover an application's sub-resources, logs RBAC is always enforced,
high-churn kinds sit in the default `resource.exclusions`, and the Dex RBAC subject is
`federated_claims.user_id` instead of `sub`. Check `rbac_policies` that name individual users, and
give roles that need logs `logs, get`.

### Controller parameters the chart no longer sets

Chart 9.0.0 removed every default under `configs.params`, so these fall back to the Argo CD v3.6.3
binary defaults:

| Parameter | Chart 7.8.26 | Binary default | Effect |
|---|---|---|---|
| `applicationsetcontroller.policy` | `sync` | `""` | ApplicationSets default to `sync` but may override it per ApplicationSet |
| `controller.self.heal.timeout.seconds` | `5` | `0` | Self-heal retries back off from 2s, by a factor of 3, up to 300s |
| `controller.status.processors` | `20` | `20` | None |
| `controller.operation.processors` | `10` | `10` | None |

Restore any you rely on through `extra_values`:

```yaml
configs:
  params:
    applicationsetcontroller.policy: sync
```

### Rolling out and back

Pin `version = "2.0.0"` exactly while rolling out. Rolling back is pinning `1.10.0` again, as long as
`resource_tracking_method` has not been changed from `label`. Once it is `annotation`, pinning
`1.10.0` puts tracking back on label and every application shows OutOfSync until it is re-applied.
