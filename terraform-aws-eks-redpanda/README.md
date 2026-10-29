# AWS EKS Redpanda Multi-Tenant Terraform Module

This module runs a Redpanda cluster on an existing EKS cluster for several tenants at
once, using the Redpanda Operator. It starts with the cheapest shape that is still
replicated, and each larger shape is a change to one input.

What it creates:

- **Redpanda Operator**, scoped to one namespace.
- **The cluster.** It is SASL-only (SCRAM-SHA-512), with auto topic creation off and
  rack awareness on.
- **One login per tenant.** Each tenant can only use topics, consumer groups and
  transactional ids prefixed `<tenant>.`, and gets the topics you list for it.
- **Client quotas** for each tenant's produce and fetch byte rate.
- **Optional:** dedicated Graviton node groups with local NVMe (one per AZ), and tiered
  storage to S3 through IRSA.

## Usage

### Cheapest: shared cluster on an existing dedicated EC2 pool

Tenant workloads may run on Fargate, but brokers require EC2: Fargate provides
neither EBS nor local NVMe. On a Fargate-first cluster, set `node_group.create = true`
with subnet IDs, or supply an existing tainted EC2 pool. By default brokers select
`redpanda.com/cluster = <name>` and tolerate `dedicated=<name>:NoSchedule`.
For an external pool, set `node_group.labels` and `node_group.taint = { key = "dedicated", value = "redpanda" }`
to match its labels and NoSchedule taint. Keep the broker namespace outside Fargate
profile selectors. The module-created node groups use the same labels and taint.

```hcl
module "redpanda" {
  source = "terraform.c0x12c.com/c0x12c/eks-redpanda/aws"
  version = "0.1.0"

  eks_cluster_name = "my-eks"

  tenants = {
    acme = {
      topics             = { orders = { partitions = 6 } }
      producer_byte_rate = 1048576
    }
    beta = {
      topics = { orders = {} }
    }
  }
}
```

### Dedicated NVMe brokers with tiered storage

```hcl
module "redpanda" {
  source = "terraform.c0x12c.com/c0x12c/eks-redpanda/aws"
  version = "0.1.0"

  eks_cluster_name = "my-eks"
  size             = "medium"
  brokers          = { replicas = 6 }

  node_group = {
    create     = true
    subnet_ids = [for s in module.vpc.private_subnets : s] # one per AZ
  }

  oidc_provider             = { arn = module.eks.oidc_provider_arn, url = module.eks.oidc_provider }
  enterprise_license_secret = { name = "redpanda-license", key = "license" }
  tiered_storage            = { enabled = true, local_retention_bytes = 10737418240 }

  tenants = { ... }
}
```

The `helm` and `kubernetes` providers must point at the EKS cluster. Clients read their
credentials from the Secret named in `tenant_secret_names[<tenant>]`, which holds the
`username`, `password`, `mechanism` and `brokers` keys.

## Scaling broker nodes

The dedicated node groups are sized from `brokers.replicas`; change that input rather than
scaling the groups by hand, because the next apply resets an out-of-band size.

## Placement on Fargate-first clusters

Brokers need a dedicated, tainted EC2 pool: Fargate has no EBS or local NVMe. The
cluster's EBS CSI node DaemonSet must tolerate that pool's taint, or PVCs never bind and
the broker pods stay Pending.

## Quotas

Quota values are per broker and measured on compressed wire bytes. A tenant's effective
ceiling is therefore roughly the quota times the broker count, and depends on how
compressible its payloads are. Quotas are applied by a post-install hook Job and
reconciled every 10 minutes by a CronJob, so a rebuilt cluster gets them back.

## Console

Without an Enterprise licence Console has no per-user login, and it reads as the
operator's bootstrap user. Front it with an authenticating proxy; do not expose it
directly.

## Examples

- [Minimal](./examples/minimal/) - cheapest shape, two tenants
- [Production](./examples/production/) - dedicated NVMe nodes, 6 brokers, tiered storage

## Sizing and scaling

Start on `small` and move along the table as load grows. Each step changes one input.
Prices are us-east-1 on-demand compute for the brokers only, read 2026-10-27.

| Profile | Brokers | Each broker | Storage | Nodes | Approx. monthly |
| --- | --- | --- | --- | --- | --- |
| `small` (default) | 3 | 1 core, 2.5Gi | 50Gi gp3 PVC | existing nodes; or 3 x m7g.large with `node_group.create` | ~$12 of gp3, or ~$180 with dedicated nodes |
| `medium` | 3 | 3 cores, 24Gi | local NVMe, 937 GB | 3 x i4g.xlarge | ~$676 |
| `large` | 3 | 7 cores, 52Gi | local NVMe, 1.9 TB | 3 x i4g.2xlarge | ~$1,350 |

Ways to grow, in order of cost:

1. **Throughput per tenant.** Raise a tenant's quotas. This costs nothing until the
   brokers saturate.
2. **Retention.** Turn on `tiered_storage`, so old segments move to S3 at about
   $0.023/GB-month instead of growing disks. This needs an Enterprise licence.
3. **Scale up.** Move `small` to `medium` to `large`. Changing storage type from EBS to
   NVMe means migrating to a new cluster, not upgrading in place, so choose it early.
4. **Scale out.** Set `brokers.replicas`, for example to 6. Partitions only move onto
   new brokers by themselves with Continuous Data Balancing (Enterprise); without it,
   move them with `rpk cluster partitions move`.
5. **Isolate a noisy tenant.** Call the module a second time with its own `name`, and
   move the tenant there.

Cross-AZ transfer often costs more than the brokers. With RF3 across three AZs, each GB
produced costs about $0.053 in transfer. Tell consumers to set `client.rack` to their
AZ, so they fetch from a replica in the same zone (`rack_awareness` is on by default).

## Tenancy model

| Control | What it prevents |
| --- | --- |
| SCRAM user per tenant, password in a Secret | anonymous access, and one tenant using another's login |
| Prefixed ACLs on `<tenant>.` | reading or writing another tenant's topics, groups or transactions |
| `auto_create_topics_enabled: false`, and no Create ACL for tenants | partition sprawl; topics exist only through this module |
| `producer_byte_rate` / `consumer_byte_rate` | one tenant saturating the brokers |
| Per-topic `retention.ms` / `retention.bytes` | one tenant filling the disks |

A tenant is a logical boundary, not a physical one. Tenants share cores, disks and the
network; quotas cap bytes per second, not partition count or a hot core. Give a tenant
its own module instance when it needs a physical boundary.

## Security notes

- **`pods/exec` on a broker is superuser access.** The chart sets the bootstrap
  superuser's credentials in the broker container's environment (`RPK_USER`/`RPK_PASS`).
  Keep `pods/exec` in this namespace out of every tenant's Kubernetes RBAC.
- **Passwords are in Terraform state.** They are generated with `random_password`, so
  the state backend must be encrypted and access-controlled.
- **TLS is off by default.** Turn on `tls_enabled` (it needs cert-manager) when any
  client is outside the trust boundary of the cluster network.

## Known limits

- **Quotas are applied by a Helm hook Job and a CronJob running `rpk`,** because there is
  no custom resource for them. Removing a tenant does not remove its quota. The Jobs do
  not handle `tls_enabled = true` yet.
- **Quotas are enforced per broker,** so a tenant can reach up to N times its quota
  across N brokers.
- **Brokers need one node each,** because the chart's anti-affinity is hard on hostname.
  Each node group therefore holds `ceil(replicas / AZs)` nodes, plus one spare for
  replacements.
- **Spot capacity is not offered.** A reclaimed node takes its instance-store replicas
  with it.

## Verification status

What has been checked (2026-10-28):

- `terraform validate` passes with Terraform 1.10.1 for the module and both examples.
- The local chart's rendered output for both example shapes validates against the
  operator v26.1.9 CRD schemas, with no fields that Kubernetes would silently prune. A
  planted bad field was caught, so the check can fail.
- The node user data renders, and its script passes `bash -n` and shellcheck in both
  storage modes.
- The tenant isolation pattern itself (users, prefixed ACLs, no topic creation, user
  quotas) was run against a live cluster on kind; see
  `docs/redpanda-multi-tenant-low-cost.md`.

Not yet checked:

- The module has not been applied anywhere.
- The NVMe user data has not been booted on an EC2 instance. Both `mdadm` on AL2023 and
  the RAID0 path are unproven.
- Tiered storage through IRSA (`cloud_storage_credentials_source: sts`) has not run.
- The quota hook Job has only been rendered, never run.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.30.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.70.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.4.1 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.tiered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.tiered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_s3_bucket.tiered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.tiered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.tiered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.tiered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [helm_release.cluster](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.admin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.bootstrap](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.superusers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.tenant](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [random_password.admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.bootstrap](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.tenant](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.node_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tiered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tiered_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [cloudinit_config.broker](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_brokers"></a> [brokers](#input\_brokers) | Per-field overrides of the sizing profile. replicas scales out; cpu\_cores and memory scale up. | <pre>object({<br/>    replicas       = optional(number)<br/>    cpu_cores      = optional(number)<br/>    memory         = optional(string)<br/>    storage_type   = optional(string) # ebs | local_nvme<br/>    storage_size   = optional(string) # ebs only<br/>    storage_class  = optional(string) # ebs only, null = cluster default<br/>    instance_types = optional(list(string))<br/>  })</pre> | `{}` | no |
| <a name="input_cluster_config"></a> [cluster\_config](#input\_cluster\_config) | Extra Redpanda cluster properties, merged over the module defaults. | `map(any)` | `{}` | no |
| <a name="input_console_enabled"></a> [console\_enabled](#input\_console\_enabled) | Deploy Redpanda Console. Off by default: without an Enterprise licence it has no per-user login, so it is an operator tool only. | `bool` | `false` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace. Set to false when it already exists. | `bool` | `true` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster Redpanda is installed into. | `string` | n/a | yes |
| <a name="input_enterprise_license_secret"></a> [enterprise\_license\_secret](#input\_enterprise\_license\_secret) | Existing Secret holding the Redpanda Enterprise licence. Needed for tiered storage and Console authentication. | <pre>object({<br/>    name = string<br/>    key  = string<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Redpanda cluster. Used for the Kubernetes resources and as part of every AWS resource name. | `string` | `"redpanda"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for the operator and the cluster. | `string` | `"redpanda"` | no |
| <a name="input_node_group"></a> [node\_group](#input\_node\_group) | Dedicated broker nodes, one managed node group per subnet (one subnet per AZ).<br/>Required for local\_nvme storage, since the module's user data prepares the instance store.<br/>Nodes are tainted dedicated=<name>:NoSchedule so nothing else lands on them.<br/>On Fargate-first clusters create this group or provide an external tainted EC2 pool.<br/>labels and taint override the default selector and NoSchedule toleration for either pool. | <pre>object({<br/>    create             = optional(bool, false)<br/>    subnet_ids         = optional(list(string), [])<br/>    kubernetes_version = optional(string)<br/>    root_volume_size   = optional(number, 50)<br/>    labels             = optional(map(string))<br/>    taint = optional(object({<br/>      key   = string<br/>      value = string<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_oidc_provider"></a> [oidc\_provider](#input\_oidc\_provider) | The EKS cluster's OIDC provider, for the IRSA role that tiered storage uses. | <pre>object({<br/>    arn = string<br/>    url = string<br/>  })</pre> | `null` | no |
| <a name="input_operator"></a> [operator](#input\_operator) | Redpanda Operator release. Set install to false when an operator already watches this namespace. | <pre>object({<br/>    install       = optional(bool, true)<br/>    chart_version = optional(string, "v26.1.9")<br/>  })</pre> | `{}` | no |
| <a name="input_rack_awareness"></a> [rack\_awareness](#input\_rack\_awareness) | Spread replicas across zones using the topology.kubernetes.io/zone node label. Also enables follower fetching for clients that set client.rack. | `bool` | `true` | no |
| <a name="input_redpanda_version"></a> [redpanda\_version](#input\_redpanda\_version) | Redpanda image tag. | `string` | `"v26.2.2"` | no |
| <a name="input_size"></a> [size](#input\_size) | Sizing profile, cheapest first:<br/>small  - 3 brokers, 1 core, 2.5Gi each, EBS volumes, requires a dedicated EC2 pool;<br/>medium - 3 brokers on dedicated i4g.xlarge, local NVMe;<br/>large  - 3 brokers on dedicated i4g.2xlarge, local NVMe.<br/>Any field of var.brokers overrides the profile. | `string` | `"small"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for every AWS resource. | `map(string)` | `{}` | no |
| <a name="input_tenants"></a> [tenants](#input\_tenants) | Tenants keyed by name. Each gets a SCRAM user, ACLs limited to topics, groups and<br/>transactional ids prefixed "<tenant>.", and the listed topics, created as "<tenant>.<topic>".<br/>Tenants cannot create topics themselves. Byte rates are per broker, in bytes per second. | <pre>map(object({<br/>    topics = optional(map(object({<br/>      partitions         = optional(number, 3)<br/>      replication_factor = optional(number, 3)<br/>      config             = optional(map(string), {})<br/>    })), {})<br/>    producer_byte_rate = optional(number)<br/>    consumer_byte_rate = optional(number)<br/>    transactions       = optional(bool, false)<br/>    extra_acls         = optional(any, [])<br/>  }))</pre> | `{}` | no |
| <a name="input_tiered_storage"></a> [tiered\_storage](#input\_tiered\_storage) | Offload closed segments to S3. Needs an Enterprise licence and oidc\_provider. local\_retention\_bytes caps what stays on broker disk per partition. | <pre>object({<br/>    enabled               = optional(bool, false)<br/>    bucket_name           = optional(string) # null = create one<br/>    force_destroy         = optional(bool, false)<br/>    local_retention_bytes = optional(number)<br/>  })</pre> | `{}` | no |
| <a name="input_tls_enabled"></a> [tls\_enabled](#input\_tls\_enabled) | TLS on the Kafka, Admin and Schema Registry listeners. Needs cert-manager in the cluster. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_secret_name"></a> [admin\_secret\_name](#output\_admin\_secret\_name) | Secret with the superuser's username, password and mechanism. Operators only. |
| <a name="output_bootstrap_brokers"></a> [bootstrap\_brokers](#output\_bootstrap\_brokers) | Kafka bootstrap address inside the EKS cluster (SASL SCRAM-SHA-512). |
| <a name="output_brokers"></a> [brokers](#output\_brokers) | Effective broker sizing after profile and overrides. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace holding the cluster and its Secrets. |
| <a name="output_node_group_names"></a> [node\_group\_names](#output\_node\_group\_names) | Dedicated broker node groups, keyed by subnet id. |
| <a name="output_tenant_secret_names"></a> [tenant\_secret\_names](#output\_tenant\_secret\_names) | Per-tenant Secret (username, password, mechanism, brokers), keyed by tenant. |
| <a name="output_tenant_topics"></a> [tenant\_topics](#output\_tenant\_topics) | Topics created for tenants, fully qualified. |
| <a name="output_tiered_storage_bucket"></a> [tiered\_storage\_bucket](#output\_tiered\_storage\_bucket) | S3 bucket used for tiered storage, or null. |
| <a name="output_tiered_storage_role_arn"></a> [tiered\_storage\_role\_arn](#output\_tiered\_storage\_role\_arn) | IRSA role the brokers use for S3, or null. |
<!-- END_TF_DOCS -->
