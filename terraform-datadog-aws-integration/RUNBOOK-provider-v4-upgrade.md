# Runbook: Datadog Terraform Provider Upgrade v3 → v4

## Overview

The Datadog Terraform provider jumped from `~> 3.81.0` to `~> 4.9.0`.  
v4.0.0 introduced breaking changes that removed the deprecated `datadog_integration_aws` resource family and require migration to `datadog_integration_aws_account`.

---

## Breaking Changes

### Removed resources (v4.0.0)
| Removed resource | Replacement |
|---|---|
| `datadog_integration_aws` | `datadog_integration_aws_account` |
| `datadog_integration_aws_lambda_arn` | `datadog_integration_aws_account` (via `logs_config.lambda_forwarder`) |
| `datadog_integration_aws_log_collection` | `datadog_integration_aws_account` (via `logs_config`) |
| `datadog_integration_aws_tag_filter` | `datadog_integration_aws_account` (via `metrics_config.tag_filters`) |

### Other breaking changes in v4.0.0

- Minimum Terraform version raised to **1.1.5**
- `datadog_application_key` data source removed (use resource instead)
- `datadog_monitor`: `locked` field removed; use `restriction_policy` resource
- `datadog_integration_aws_event_bridge`: upgraded to v2 API

---

## Attribute Migration Map

### `datadog_integration_aws` → `datadog_integration_aws_account`

| Old attribute | New location | Notes |
|---|---|---|
| `account_id` | `aws_account_id` | Direct rename |
| `role_name` | `auth_config.aws_auth_config_role.role_name` | Now nested |
| `extended_resource_collection_enabled` | `resources_config.extended_collection` | Renamed, nested |
| `metrics_collection_enabled` | `metrics_config.enabled` | Renamed, nested |
| `account_specific_namespace_rules` (map(bool)) | `metrics_config.namespace_filters.include_only` or `exclude_only` | Type change: map → list of AWS namespace strings |
| `external_id` (computed) | `auth_config.aws_auth_config_role.external_id` | Still computed; Datadog auto-generates if omitted |

### New required blocks (use empty block for provider defaults)

```hcl
aws_partition  = "aws"          # required top-level attribute
aws_regions {}                  # empty = include all regions
logs_config    { lambda_forwarder {} }
metrics_config { namespace_filters {} }
resources_config {}
traces_config  { xray_services {} }
```

#### Attribute explanations

**`aws_partition = "aws"`**
Identifies the AWS partition the account belongs to. Must be one of `"aws"` (standard global regions), `"aws-cn"` (China regions), or `"aws-us-gov"` (GovCloud). This is a top-level required string — the provider will reject the resource if omitted.

**`aws_regions {}`**
Controls which AWS regions Datadog monitors. An empty block means **all current and future regions** are included automatically. To restrict to specific regions, populate the `include_only` argument:
```hcl
aws_regions {
  include_only = ["us-east-1", "us-west-2", "ap-southeast-1"]
}
```

**`logs_config { lambda_forwarder {} }`**
Configures log collection settings. The nested `lambda_forwarder` block defines which Lambda functions ship logs to Datadog (by ARN or prefix). An empty `lambda_forwarder {}` block keeps log forwarding enabled with provider defaults (no ARN filters). To add forwarder ARNs:
```hcl
logs_config {
  lambda_forwarder {
    lambdas  = ["arn:aws:lambda:us-east-1:123456789012:function:datadog-forwarder"]
    sources  = ["s3"]
  }
}
```

**`metrics_config { namespace_filters {} }`**
Controls CloudWatch metric collection. The nested `namespace_filters` block accepts `include_only` or `exclude_only` lists of AWS CloudWatch namespace strings. An empty `namespace_filters {}` block collects metrics from **all namespaces**. To restrict:
```hcl
metrics_config {
  namespace_filters {
    include_only = ["AWS/ElastiCache", "AWS/RDS", "AWS/EC2"]
    # or to exclude specific ones:
    # exclude_only = ["AWS/Billing"]
  }
}
```
`include_only` and `exclude_only` are mutually exclusive — setting both is a runtime error enforced by the `lifecycle.precondition` in `main.tf`.

**`resources_config {}`**
Controls extended resource collection (resource tags, configurations, and relationships beyond metrics). The key argument is `extended_collection` (bool, default `true`) which enables collection of detailed resource metadata used to populate Datadog's infrastructure list and resource catalog. An empty block uses provider defaults (extended collection on):
```hcl
resources_config {
  extended_collection = true   # collect resource configs and tags
  cloud_security_posture_management_collection = false  # CSPM — enable if using Datadog Cloud Security
}
```

**`traces_config { xray_services {} }`**
Configures AWS X-Ray trace ingestion. The nested `xray_services` block controls which X-Ray services are scraped. An empty `xray_services {}` block enables X-Ray collection for all services. To restrict to specific services:
```hcl
traces_config {
  xray_services {
    include_only = ["ApiGateway", "Lambda"]
  }
}
```
Leave as `xray_services {}` if you do not use X-Ray — Datadog will simply find no traces to ingest.

### Namespace filter format change

Old (`account_specific_namespace_rules`):
```hcl
account_specific_namespace_rules = {
  "elasticache" = true
  "rds"         = true
  "ec2"         = false
}
```

New (`namespace_filters`):
```hcl
metrics_config {
  namespace_filters {
    # Collect specific namespaces (default is null — all namespaces):
    # include_only = ["AWS/ElastiCache", "AWS/RDS", "AWS/EC2", "AWS/Lambda"]

    # Or exclude specific namespaces instead (mutually exclusive with include_only):
    # exclude_only = ["AWS/Billing"]
  }
}
```

Common service name → AWS namespace mapping:

| Old key | AWS namespace |
|---|---|
| `elasticache` | `AWS/ElastiCache` |
| `rds` | `AWS/RDS` |
| `ec2` | `AWS/EC2` |
| `lambda` | `AWS/Lambda` |
| `s3` | `AWS/S3` |
| `ecs` | `AWS/ECS` |
| `dynamodb` | `AWS/DynamoDB` |
| `kinesis` | `AWS/Kinesis` |
| `sqs` | `AWS/SQS` |
| `sns` | `AWS/SNS` |
| `elb` / `application_elb` | `AWS/ApplicationELB` |
| `network_elb` | `AWS/NetworkELB` |
| `redshift` | `AWS/Redshift` |
| `es` | `AWS/ES` |
| `cloudfront` | `AWS/CloudFront` |
| `autoscaling` | `AWS/AutoScaling` |
| `ebs` | `AWS/EBS` |
| `eks` | `AWS/EKS` |
| `firehose` | `AWS/Firehose` |
| `kafka` | `AWS/Kafka` |
| `mq` | `AWS/AmazonMQ` |
| `neptune` | `AWS/Neptune` |
| `route53` | `AWS/Route53` |
| `sagemaker` | `AWS/SageMaker` |
| `states` | `AWS/States` |
| `wafv2` | `AWS/WAFV2` |

Both `namespace_filters_include_only` and `namespace_filters_exclude_only` default to `null`, which collects all namespaces. Set one or the other to restrict collection — they are mutually exclusive.

---

## Changes Made in This Repository

### `versions.tf`
- `~> 3.81.0` → `~> 4.9.0`

### `main.tf`
- Replaced `resource "datadog_integration_aws" "sandbox"` with `resource "datadog_integration_aws_account" "sandbox"`
- Restructured flat attributes into nested blocks (`auth_config`, `metrics_config`, `resources_config`, etc.)
- Updated `external_id` reference: `datadog_integration_aws.sandbox.external_id` → `datadog_integration_aws_account.sandbox.auth_config.aws_auth_config_role.external_id`

### `variables.tf`
- Removed: `aws_services_enabled` (`map(bool)`)
- Added: `namespace_filters_include_only` (`list(string)`, default: `null` — collect all namespaces)
- Added: `namespace_filters_exclude_only` (`list(string)`, default `null`)

### `main.tf` — mutual exclusivity guard
A `lifecycle.precondition` on `datadog_integration_aws_account` enforces that `namespace_filters_include_only` and `namespace_filters_exclude_only` are never both set:

```hcl
lifecycle {
  precondition {
    condition     = !(var.namespace_filters_include_only != null && var.namespace_filters_exclude_only != null)
    error_message = "namespace_filters_include_only and namespace_filters_exclude_only are mutually exclusive; set only one."
  }
}
```

### `locals.tf`
- Removed: `aws_services_enabled` local map (no longer needed; namespace selection moved to variable)
- Consolidated specific `elasticache:DescribeCacheClusters`, `elasticache:ListTagsForResource`, `elasticache:DescribeEvents` permissions into existing wildcards `elasticache:Describe*` and `elasticache:List*` — no net permissions change

### `examples/complete/main.tf`
- Replaced `aws_services_enabled` map with a representative `namespace_filters_include_only` subset to illustrate usage

---

## Upgrade Procedure

> **Why state rm → import (not just import)?**
> Terraform tracks resources by `<type>.<name>`. The type name changed from
> `datadog_integration_aws` to `datadog_integration_aws_account`, so Terraform
> cannot carry the state entry across automatically. If you skip `state rm` and
> run `terraform plan`, Terraform will plan to **destroy** the old resource and
> **create** a new one — which would delete the live Datadog AWS integration.
> The correct sequence is always: **back up → state rm → import → plan → apply**.

### Step 1 — Back up current state

Always take a snapshot before any state surgery:

```bash
# Pull the current state to a local file (use a date suffix so you can find it later)
terraform state pull > terraform-state-backup-$(date +%Y%m%d-%H%M%S).tfstate

# Confirm the backup is non-empty
wc -c terraform-state-backup-*.tfstate
```

Keep this file. You will need it for rollback Option A.

### Step 2 — Note the existing resource details

Capture the AWS account ID and role name from the current state before removing it:

```bash
terraform state show datadog_integration_aws.sandbox
```

Example output:
```
# datadog_integration_aws.sandbox:
resource "datadog_integration_aws" "sandbox" {
    account_id                          = "123456789012"
    role_name                           = "DatadogAWSIntegrationRole"
    external_id                         = "abc123..."
    metrics_collection_enabled          = "true"
    ...
}
```

Note down `account_id` — you will need it when querying the Datadog API.

### Step 3 — Update provider version

The `versions.tf` already pins `~> 4.9.0`. Run:

```bash
terraform init -upgrade
```

### Step 4 — Remove the old resource from state

```bash
# Verify the address before removing
terraform state list | grep datadog_integration_aws

# Remove the old resource type from state (does NOT touch the live Datadog resource)
terraform state rm datadog_integration_aws.sandbox
```

After this command, `terraform plan` would show a `+create` for `datadog_integration_aws_account.sandbox` because the state is empty for that address. **Do not apply yet** — import first.

### Step 5 — Retrieve the Datadog account config ID

The new resource type uses a Datadog-internal UUID as its import ID, not the AWS account ID.

```bash
# Replace 123456789012 with your AWS account ID from Step 2
export DD_API_KEY="<your-datadog-api-key>"
export DD_APP_KEY="<your-datadog-app-key>"
export AWS_ACCOUNT_ID="123456789012"

curl -s "https://api.datadoghq.com/api/v2/integration/aws/accounts" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  | jq -r '.data[] | select(.attributes.aws_account_id == "'${AWS_ACCOUNT_ID}'") | .id'
```

Example output:
```
a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

This UUID is the import ID for the next step.

### Step 6 — Import into the new resource address

```bash
terraform import datadog_integration_aws_account.sandbox "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
```

Verify the import populated state correctly:

```bash
terraform state show datadog_integration_aws_account.sandbox
```

You should see `aws_account_id`, `auth_config`, `metrics_config`, etc. populated.

### Step 7 — Validate the plan

```bash
terraform plan
```

Expected: **no destructive changes**. The plan may show minor in-place attribute updates (provider-side defaults being reconciled) but must not show any `destroy` or `create` actions on `datadog_integration_aws_account.sandbox`.

If the plan shows a destroy + create, stop and investigate before proceeding — do **not** apply.

### Step 8 — Apply

```bash
terraform apply
```

### Step 9 — Verify in Datadog UI

1. Navigate to **Integrations → AWS** in Datadog.
2. Confirm the AWS account still appears and the integration status is healthy.
3. Check that metric collection is active for the expected namespaces (all namespaces by default; use `namespace_filters_include_only` or `namespace_filters_exclude_only` to restrict).

---

## Rollback

If the upgrade causes issues, choose the option that matches your situation.

---

### Option A — Restore from the state backup (preferred)

Use this when you have the backup file created in Step 1 and have not yet destroyed any infrastructure.

**1. Revert the code**

```bash
git checkout master -- versions.tf main.tf variables.tf locals.tf examples/complete/main.tf
```

**2. Remove the new state entry**

```bash
# Confirm the current address
terraform state list | grep datadog_integration_aws_account

terraform state rm datadog_integration_aws_account.sandbox
```

**3. Push the backup state**

```bash
# Identify your backup file (created in Step 1 of the upgrade)
ls terraform-state-backup-*.tfstate

# Push the backup back — this restores datadog_integration_aws.sandbox in state
terraform state push terraform-state-backup-<timestamp>.tfstate
```

**4. Downgrade the provider lock file**

```bash
terraform init -upgrade
```

**5. Verify**

```bash
terraform state show datadog_integration_aws.sandbox   # should show the old resource
terraform plan                                         # expected: no changes
```

---

### Option B — Re-import without a backup

Use this when no backup is available (e.g., the backup was lost or the upgrade was done without taking one).

**1. Revert the code**

```bash
git checkout master -- versions.tf main.tf variables.tf locals.tf examples/complete/main.tf
```

**2. Downgrade the provider lock file**

```bash
terraform init -upgrade
```

**3. Remove the new state entry (if it still exists)**

```bash
terraform state list | grep datadog_integration_aws_account
# If it appears, remove it:
terraform state rm datadog_integration_aws_account.sandbox
```

**4. Re-import the old resource type**

The old `datadog_integration_aws` resource uses the **AWS account ID** (12-digit number) as its import ID — not the Datadog UUID:

```bash
# Replace with your actual AWS account ID
terraform import datadog_integration_aws.sandbox "123456789012"
```

Example output:
```
datadog_integration_aws.sandbox: Importing from ID "123456789012"...
datadog_integration_aws.sandbox: Import prepared!
datadog_integration_aws.sandbox: Refreshing state... [id=123456789012]

Import successful!
```

**5. Verify the imported state**

```bash
terraform state show datadog_integration_aws.sandbox
```

Check that `account_id`, `role_name`, and `metrics_collection_enabled` match what you recorded in Step 2 of the upgrade.

**6. Validate the plan**

```bash
terraform plan
```

Expected: no destructive changes. If the plan shows updates to `account_specific_namespace_rules` or other attributes, review them carefully — they reflect drift between the live resource and the previous Terraform configuration. Apply only if the changes are safe.

```bash
terraform apply
```

---

## References

- [Datadog Provider v4.0.0 Release Notes](https://github.com/DataDog/terraform-provider-datadog/releases/tag/v4.0.0)
- [datadog_integration_aws_account resource docs](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws_account)
- [datadog_integration_aws_available_namespaces data source](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/data-sources/integration_aws_available_namespaces)
- [AWS Integration IAM Policy](https://docs.datadoghq.com/integrations/amazon_web_services/#aws-integration-iam-policy)
