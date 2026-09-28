# terraform-aws-eks-multi-tenant-alb

Creates a dedicated ALB on EKS for per-tenant hosts, with one wildcard certificate per tenant.

Each tenant gets hosts like `auth.acme.example.com`. The module creates, through the
AWS Load Balancer Controller:

- An ALB with an HTTPS-only listener and a default `404` response.
- One ACM wildcard certificate per tenant (`*.<tenant>.<domain>`), DNS-validated and attached with SNI.
- One ingress per service, in the service's namespace, with one host rule per tenant host.
- One Route53 `A` alias record per host.

The ALB forwards the `Host` header unchanged, so the backend can resolve the tenant from it.
To add a tenant, add an entry to `tenant_hosts`.

## Usage

```hcl
module "eks_multi_tenant_alb" {
  source  = "terraform.c0x12c.com/c0x12c/eks-multi-tenant-alb/aws"
  version = "~> 0.1"

  name    = "example-tenant"
  domain  = "example.com"
  zone_id = "Z0123456789EXAMPLE"

  # tenant => { service => host }. The host is relative to domain and must be <label>.<tenant>.
  tenant_hosts = {
    acme = {
      auth   = "auth.acme"
      rental = "rental.acme"
    }
  }

  services = {
    auth   = { namespace = "service-auth", name = "service-auth", port = 80 }
    rental = { namespace = "service-rental", name = "service-rental", port = 80 }
  }
}
```

## Notes

- **Requires** the AWS Load Balancer Controller in the cluster, and an `alb` IngressClass.
- **Health checks** call `health_check_path` with the target IP as `Host`, not a tenant host.
  If the backend rejects requests with no known tenant, it must exempt this path.
- **A second level needs its own certificate.** A `*.<domain>` certificate does not cover
  `auth.acme.<domain>`, so the module issues `*.<tenant>.<domain>` per tenant. An ALB listener
  takes 25 certificates by default.
- **Deletion protection** is on by default. To remove the module, set `deletion_protection = false`
  and apply first.

## Examples

See [`examples/complete`](examples/complete) for a runnable example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.33 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | ../terraform-aws-acm | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [kubernetes_ingress_v1.alb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_ingress_v1.service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [aws_lb_hosted_zone_id.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_hosted_zone_id) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | S3 bucket for ALB access logs. Access logs are off when null. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable ALB deletion protection. Set to false and apply before removing the module. | `bool` | `true` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Root domain of the tenant hosts, e.g. example.com. A host "auth.acme" is served at auth.acme.<domain>. | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Target group health check path. ALB health checks send the target IP as Host, so this path must not require a tenant host. | `string` | `"/health"` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | ALB idle timeout in seconds. | `number` | `60` | no |
| <a name="input_ingress_namespace"></a> [ingress\_namespace](#input\_ingress\_namespace) | Namespace of the ingress that creates the ALB and its default 404 rule. | `string` | `"kube-system"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ALB. Also used as the ingress group name and as the prefix of the ingress names. | `string` | n/a | yes |
| <a name="input_scheme"></a> [scheme](#input\_scheme) | ALB scheme: internet-facing or internal. | `string` | `"internet-facing"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security groups for the ALB. When empty, the AWS Load Balancer Controller creates one. | `list(string)` | `[]` | no |
| <a name="input_services"></a> [services](#input\_services) | Kubernetes backend for each service key used in tenant\_hosts. | <pre>map(object({<br/>    namespace = string<br/>    name      = string<br/>    port      = number<br/>  }))</pre> | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy of the HTTPS listener. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the ALB and the certificates. | `map(string)` | `{}` | no |
| <a name="input_tenant_hosts"></a> [tenant\_hosts](#input\_tenant\_hosts) | Hosts per tenant, as tenant => { service => host }. The host is relative to domain and must be <label>.<tenant>, so the tenant's *.<tenant>.<domain> certificate covers it. The service key must exist in services. | `map(map(string))` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 hosted zone ID for the certificate validation records and the host records. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arns"></a> [certificate\_arns](#output\_certificate\_arns) | ARN of each tenant's wildcard certificate, by tenant. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS name of the ALB. |
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | Ingress group name of the ALB. Add an ingress with this group name to put more rules on the same ALB. |
| <a name="output_hostnames"></a> [hostnames](#output\_hostnames) | Full host name of each route, by "<tenant>/<service>". |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Route53 hosted zone ID of the ALB, for alias records. |
<!-- END_TF_DOCS -->
