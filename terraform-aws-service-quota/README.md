# terraform-aws-service-quota

Manages AWS service quotas as code and warns on every plan when the value AWS applies differs
from the value in code: a request still pending, approved at a lower value, denied, or a
quota changed in the console.

Each quota is an `aws_servicequotas_service_quota` resource, which submits an increase
request when `value` exceeds the applied value. Once a request leaves `PENDING`, the resource
alone cannot tell whether AWS approved it, approved less, or denied it. The module therefore
also reads the applied value with the `aws_servicequotas_service_quota` data source on every
plan and reports any mismatch through a `check` block (a warning, never a failure) and the
`quotas_out_of_sync` output. Data sources are read even under `plan -refresh=false`, so the
warning also appears in pipelines that skip refresh.

To find a `service_code` and `quota_code`, use the
[service quota catalog](../docs/service-quotas/README.md).

## Usage

One module instance manages the quotas of its provider's region.

```hcl
module "service_quotas" {
  source  = "terraform.c0x12c.com/c0x12c/service-quota/aws"
  version = "~> 0.1.0"

  quotas = {
    fargate_on_demand_vcpus = {
      service_code = "fargate"
      quota_code   = "L-3032A538"
      value        = 60
    }
    ec2_on_demand_standard_vcpus = {
      service_code = "ec2"
      quota_code   = "L-1216C47A"
      value        = 96
    }
  }
}

# Root modules only expose root outputs to `terraform output`; re-export the drift map.
output "service_quotas_out_of_sync" {
  description = "Quotas whose AWS-applied value differs from code; empty when in sync. Reflects the last apply; run a plan for the current state."
  value       = module.service_quotas.quotas_out_of_sync
}
```

Raising a quota is a one-line change to `value`; the apply submits the request. Read the
applied value first so you never ask for less than you have:

```bash
aws service-quotas get-service-quota --service-code fargate --quota-code L-3032A538 --query 'Quota.Value'
```

### Plan or output: which one shows drift

- **Is any quota out of sync right now?** Run a plan. It reads the applied values from AWS,
  prints the `quotas_match_code` warning, and shows the new `quotas_out_of_sync` value under
  "Changes to Outputs".
- **What did the last apply see?** `terraform output -json service_quotas_out_of_sync`. It
  reads state only, so after AWS approves or denies a request it keeps showing the old values
  until the next apply.

### Adopt quotas that are already raised

Quotas raised in the console already have a value. Set `value` to the applied value and
import them, so the first apply submits no increase request. The import ID is
`service_code/quota_code`. Remove the `import` block after the first apply.

```hcl
import {
  for_each = local.quotas # the same map passed to the module
  to       = module.service_quotas.aws_servicequotas_service_quota.this[each.key]
  id       = "${each.value.service_code}/${each.value.quota_code}"
}
```

The plan must show only imports (`N to import, 0 to add, 0 to change, 0 to destroy`). A
change means `value` differs from the applied value and the apply would submit a request.

### Global quotas

IAM and other account-wide quotas are listed only in `us-east-1` (see the catalog's
"Global quotas" section). Manage them with a second instance on a `us-east-1` provider:

```hcl
provider "aws" {
  alias  = "global"
  region = "us-east-1"
}

module "global_service_quotas" {
  source  = "terraform.c0x12c.com/c0x12c/service-quota/aws"
  version = "~> 0.1.0"

  providers = { aws = aws.global }

  quotas = {
    iam_roles_per_account = {
      service_code = "iam"
      quota_code   = "L-FE177D64"
      value        = 2000
    }
  }
}
```

## Lifecycle

| Situation | What Terraform shows | What to do |
|---|---|---|
| Request pending (just applied) | `quotas_match_code` warning: code above applied. No resource change while the request is `PENDING` or `CASE_OPENED`. | Wait. Large increases go through a support case and can take hours. |
| Approved at the requested value | No warning, no change. | Nothing. |
| Approved at a lower value | Warning with both values. With refresh, also a planned update. | Follow [Resolve a drift warning](#resolve-a-drift-warning). |
| Denied | Warning, applied value unchanged. With refresh, also a planned update. | Follow [Resolve a drift warning](#resolve-a-drift-warning), then talk to AWS Support before asking again. |
| Raised or changed in the console | Warning with both values. With refresh, also a planned update. | Follow [Resolve a drift warning](#resolve-a-drift-warning). |
| Import while a console request is pending | The import records the applied value; Terraform cannot see a request it did not submit. Code set to the requested value plans an update that submits a second request. | Import with `value` equal to the applied value, and raise it in code after AWS decides. |
| Remove a quota from code or destroy | Terraform forgets the quota; nothing is sent to AWS. | Nothing. AWS keeps the applied value. |
| Lower a value | An update that AWS cannot fulfil: quotas cannot be decreased through this API. | Never lower a value. Set it to the applied value instead. |

A wrong `quota_code` or `service_code` fails the plan: the data source finds no quota for it.

### Resolve a drift warning

The warning compares code with the value AWS applies, read live on every plan. The resource state
is a separate copy that only a refresh updates, and every planned update of the resource submits a
new increase request. Under `plan -refresh=false` the state still holds the value of the last
request, so setting `value` to the applied value clears the warning while the plan still shows an
update from that stale value. Applying it submits a request for a value AWS already applies.

1. Set `value` to the applied value shown in the warning.
2. Run a plan **with refresh enabled** (no `-refresh=false`), or sync the state first with
   `terraform apply -refresh-only`.
3. Confirm the warning is gone and the plan shows no update to
   `aws_servicequotas_service_quota.this["<key>"]`.
4. Only then apply. A pipeline that applies with `-refresh=false` needs a refresh-enabled run for
   this change.

## Examples

See [`examples/complete`](examples/complete) for adopting two quotas with an `import` block.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.73.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_servicequotas_service_quota.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicequotas_service_quota) | resource |
| [aws_servicequotas_service_quota.applied](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicequotas_service_quota) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_quotas"></a> [quotas](#input\_quotas) | Service quotas to manage in the provider's region, keyed by a stable name of your choice.<br/>`value` is the value you want AWS to apply. When adopting a quota that is already raised,<br/>set `value` to the currently applied value so the import submits no increase request.<br/>Never set a value below the applied one: AWS does not lower quotas through this API. | <pre>map(object({<br/>    service_code = string<br/>    quota_code   = string<br/>    value        = number<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_quotas"></a> [quotas](#output\_quotas) | Per quota key: the value in code, the value AWS applies now, the AWS default, quota and service names, ARN, whether the quota is adjustable, and the ID and status of the last increase request Terraform submitted. |
| <a name="output_quotas_out_of_sync"></a> [quotas\_out\_of\_sync](#output\_quotas\_out\_of\_sync) | Quotas whose AWS-applied value differs from code, as { code\_value, applied\_value } per key; empty when in sync. Re-export it from the root module to read it with `terraform output`, which shows what the last apply saw; a plan shows the current state. |
<!-- END_TF_DOCS -->
