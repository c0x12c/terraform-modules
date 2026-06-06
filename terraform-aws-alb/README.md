# External AWS Application Load Balancer (ALB) Terraform module

Terraform module which creates external Application Load Balancer resources on AWS:

- An ALB with HTTP (auto redirect to HTTPS) and HTTPS listener rules, with some default routing rules.
- A security group for this ALB which should allow inbound traffic only on port 80 and 443.

## Usage

### External ALB

```hcl
module "alb" {
  source = "github.com/spartan-stratos/terraform-modules//aws/alb?ref=v0.1.63"

  name              = "example"
  vpc_id            = "vpc-1234567899"
  public_subnets = []
  security_groups = ["sg-1234567899"]
  certificate_arn   = ""
  health_check_path = "/health"
  idle_timeout      = 4000
  tags = {
    Environment = "dev"
  }
}

```

## Examples

- [Example](examples/complete/).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The ARN of the certificate that the ALB uses for https | `string` | n/a | yes |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. | `bool` | `false` | no |
| <a name="input_enabled_http_port"></a> [enabled\_http\_port](#input\_enabled\_http\_port) | Whether to allow HTTP (80) port through ALB security group. | `bool` | `true` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Path to check if the service is healthy, e.g. "/status" | `string` | n/a | yes |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | ALB idle timeout | `number` | `60` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | If true, the LB will be internal | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | the name of the alb | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type `network`. Changing this value for load balancers of type `network` will force a recreation of the resource | `list(string)` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security group IDs to assign to the LB | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the load balancer we created |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The DNS name of the load balancer |
| <a name="output_listener_https_arn"></a> [listener\_https\_arn](#output\_listener\_https\_arn) | The ARN of the https listener |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The zone\_id of the load balancer to assist with creating DNS records |
<!-- END_TF_DOCS -->