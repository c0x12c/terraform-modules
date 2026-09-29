# terraform-aws-eks-multi-tenant-alb

Creates a dedicated ALB on EKS that routes per-tenant hosts to services, with optional ACM certificates and Route53 records.

Each tenant gets one host per service, built from `host_template`, e.g. `auth.acme.example.com`.
Through the AWS Load Balancer Controller, the module creates:

- An ALB with an HTTPS-only listener and a default `404` response.
- One ingress per service, in the service's namespace, with one host rule per tenant.
- One DNS-validated ACM wildcard certificate per parent domain of the hosts, attached with SNI (optional).
- One Route53 `A` alias record per host (optional).

The ALB forwards the `Host` header unchanged, so the backend can resolve the tenant from it.

## Usage

```hcl
module "eks_multi_tenant_alb" {
  source  = "terraform.c0x12c.com/c0x12c/eks-multi-tenant-alb/aws"
  version = "~> 0.1"

  name    = "example-tenant"
  domain  = "example.com"
  zone_id = "Z0123456789EXAMPLE"

  tenants       = ["acme"]
  host_template = "{service}.{tenant}" # auth.acme.example.com

  services = {
    auth   = { namespace = "service-auth", name = "service-auth", port = 80 }
    rental = { namespace = "service-rental", name = "service-rental", port = 80 }
  }
}
```

To add a tenant, add it to `tenants`. To change the host names, change `domain` or `host_template`.

## Host schemes

| `host_template` | `tenants` | Hosts | Certificates created |
|---|---|---|---|
| `{service}.{tenant}` (default) | `["acme"]` | `auth.acme.example.com` | `*.acme.example.com`, one per tenant |
| `{tenant}.{service}` | `["acme"]` | `acme.auth.example.com` | `*.auth.example.com`, one per service |
| `{tenant}.{service}` | `["*"]` | `*.auth.example.com`, for every tenant | `*.auth.example.com`, one per service |
| `{tenant}-{service}` | `["acme"]` | `acme-auth.example.com` | `*.example.com`, or an existing one in `certificate_arns` |

With `tenants = ["*"]`, a new tenant needs no Terraform change: one host rule, certificate and DNS
record per service serve every tenant, and the backend rejects unknown tenants.

## Notes

- **Requires** the AWS Load Balancer Controller in the cluster, and an `alb` IngressClass.
- **Health checks** call `health_check_path`, or the service's own `health_check_path`, with the target
  IP as `Host`, not a tenant host. If the backend rejects requests with no known tenant, it must exempt this path.
- **Certificates.** A wildcard certificate covers one level only, so the module issues `*.<parent>` for
  each distinct parent domain of the hosts. To use certificates you already have, set
  `create_certificates = false` and pass them in `certificate_arns`. An ALB listener takes 25
  certificates by default.
- **DNS.** Set `create_dns_records = false` when another system manages DNS, and point the hosts at
  the `dns_name` output. `zone_id` is needed only when the module creates certificates or records.
- **Deletion protection** is on by default. To remove the module, set `deletion_protection = false`
  and apply first.

## Examples

- [`examples/complete`](examples/complete): two tenants, the default host scheme, and every certificate and DNS input.
- [`examples/wildcard-tenant`](examples/wildcard-tenant): one wildcard host per service for every tenant.
- [`examples/existing-certificate`](examples/existing-certificate): an existing certificate, and DNS managed elsewhere.

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
| <a name="input_certificate_arns"></a> [certificate\_arns](#input\_certificate\_arns) | ARNs of existing ACM certificates to attach to the HTTPS listener, in addition to the created ones. Use this when a certificate you already have covers the hosts. | `list(string)` | `[]` | no |
| <a name="input_create_certificates"></a> [create\_certificates](#input\_create\_certificates) | Create one DNS-validated ACM wildcard certificate per parent domain of the hosts, e.g. *.acme.<domain> for auth.acme.<domain>. Set to false to use only certificate\_arns. | `bool` | `true` | no |
| <a name="input_create_dns_records"></a> [create\_dns\_records](#input\_create\_dns\_records) | Create a Route53 A alias record to the ALB for each host. Set to false when DNS is managed elsewhere. | `bool` | `true` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable ALB deletion protection. Set to false and apply before removing the module. | `bool` | `true` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Root domain of the hosts, e.g. example.com. Every host is host\_template followed by .<domain>. | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Target group health check path for every service that does not set its own. ALB health checks send the target IP as Host, so this path must not require a tenant host. | `string` | `"/health"` | no |
| <a name="input_host_template"></a> [host\_template](#input\_host\_template) | Host of each route, relative to domain. {tenant} and {service} are replaced: "{service}.{tenant}" serves auth.acme.<domain>, "{tenant}.{service}" serves acme.auth.<domain>. | `string` | `"{service}.{tenant}"` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | ALB idle timeout in seconds. | `number` | `60` | no |
| <a name="input_ingress_namespace"></a> [ingress\_namespace](#input\_ingress\_namespace) | Namespace of the ingress that creates the ALB and its default 404 rule. | `string` | `"kube-system"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ALB. Also used as the ingress group name and as the prefix of the ingress names. | `string` | n/a | yes |
| <a name="input_scheme"></a> [scheme](#input\_scheme) | ALB scheme: internet-facing or internal. | `string` | `"internet-facing"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security groups for the ALB. When empty, the AWS Load Balancer Controller creates one. | `list(string)` | `[]` | no |
| <a name="input_services"></a> [services](#input\_services) | Kubernetes backend of each service. The key is the {service} value in host\_template. health\_check\_path overrides the module-wide health\_check\_path for that service. | <pre>map(object({<br/>    namespace         = string<br/>    name              = string<br/>    port              = number<br/>    health_check_path = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy of the HTTPS listener. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the ALB and the certificates. | `map(string)` | `{}` | no |
| <a name="input_tenants"></a> [tenants](#input\_tenants) | Tenant names. Each tenant gets one host per service, built from host\_template. "*" is a wildcard tenant: one host rule, certificate and DNS record per service serve every tenant. It needs {tenant} as the leftmost label of host\_template. | `set(string)` | n/a | yes |
| <a name="input_wafv2_arn"></a> [wafv2\_arn](#input\_wafv2\_arn) | ARN of a WAFv2 web ACL to associate with the ALB. No WAF when null. | `string` | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 hosted zone ID for the certificate validation records and the host records. Required when create\_certificates or create\_dns\_records is true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arns"></a> [certificate\_arns](#output\_certificate\_arns) | ARN of each certificate the module created, by certificate domain (e.g. "*.acme.example.com"). Empty when create\_certificates is false. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS name of the ALB. |
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | Ingress group name of the ALB. Add an ingress with this group name to put more rules on the same ALB. |
| <a name="output_hostnames"></a> [hostnames](#output\_hostnames) | Full host name of each route, by "<tenant>/<service>". |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Route53 hosted zone ID of the ALB, for alias records. |
<!-- END_TF_DOCS -->
