# AWS Github Actions Self Hosted Runner

Terraform module which creates resources for managing GitHub Actions Self-Hosted Runners on AWS.

## Usage

### Create Github Actions Self Hosted Runner

```hcl
module "github_self_host_runner" {
  source = "github.com/spartan-stratos/terraform-modules//aws/github-self-host-runner?ref=v0.1.65"

  github_actions_runner_registration_token = "example"
  org_name                                 = "example"
  security_group_ids = ["sg-1234567890abcdef0"]
  custom_ami_name                          = "example"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]
}
```

## Examples

- [Example](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name                                                                                                                        | Type     |
|-----------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_ami_from_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami_from_instance) | resource |
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                   | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)     | resource |

## Inputs

| Name                                                                                                                                                               | Description                                                                         | Type           | Default                         | Required |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|----------------|---------------------------------|:--------:|
| <a name="input_custom_ami_name"></a> [custom\_ami\_name](#input\_custom\_ami\_name)                                                                                | The name of the custom AMI to use for the EC2 instances.                            | `string`       | n/a                             |   yes    |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity)                                                                               | The desired number of EC2 instances in the Auto Scaling Group.                      | `number`       | `1`                             |    no    |
| <a name="input_github_actions_runner_registration_token"></a> [github\_actions\_runner\_registration\_token](#input\_github\_actions\_runner\_registration\_token) | The token for registering the GitHub Runner with the GitHub Organization.           | `string`       | n/a                             |   yes    |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period)                                                | The duration (in seconds) for the Auto Scaling Group's health check grace period.   | `number`       | `600`                           |    no    |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint)                                                                                        | The configuration for enabling or disabling the instance metadata service endpoint. | `string`       | `"enabled"`                     |    no    |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens)                                                                                              | The configuration for the instance metadata service tokens.                         | `string`       | `"optional"`                    |    no    |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)                                                                                        | The EC2 instance type to use for the GitHub Runner.                                 | `string`       | `"t3.micro"`                    |    no    |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size)                                                                                                       | The maximum number of EC2 instances in the Auto Scaling Group.                      | `number`       | `1`                             |    no    |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size)                                                                                                       | The minimum number of EC2 instances in the Auto Scaling Group.                      | `number`       | `1`                             |    no    |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name)                                                                                                       | The name of the GitHub Organization to register the GitHub Runner with.             | `string`       | n/a                             |   yes    |
| <a name="input_runner_home"></a> [runner\_home](#input\_runner\_home)                                                                                              | The home directory for the GitHub Runner.                                           | `string`       | `"/home/ubuntu/actions-runner"` |    no    |
| <a name="input_runner_labels"></a> [runner\_labels](#input\_runner\_labels)                                                                                        | Labels assigned to the GitHub Runner.                                               | `string`       | `"self-hosted,ec2"`             |    no    |
| <a name="input_runner_version"></a> [runner\_version](#input\_runner\_version)                                                                                     | The version of the GitHub Runner software to be installed.                          | `string`       | `"2.321.0"`                     |    no    |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids)                                                                       | The list of security group IDs.                                                     | `list(string)` | n/a                             |   yes    |
| <a name="input_source_ami"></a> [source\_ami](#input\_source\_ami)                                                                                                 | The AMI ID for the EC2 instance used by the source instance.                        | `string`       | `"ami-00c257e12d6828491"`       |    no    |
| <a name="input_source_instance_type"></a> [source\_instance\_type](#input\_source\_instance\_type)                                                                 | The EC2 instance type to use by the source instance                                 | `string`       | `"t3.micro"`                    |    no    |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)                                                                                                 | The list of subnets for the EC2 instances of the Auto Scaling Group.                | `list(string)` | n/a                             |   yes    |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version)                                                                            | The version of Terraform to be used.                                                | `string`       | `"1.10.1"`                      |    no    |
| <a name="input_update_default_launch_template_version"></a> [update\_default\_launch\_template\_version](#input\_update\_default\_launch\_template\_version)       | Whether to update the default version of the launch template.                       | `bool`         | `true`                          |    no    |

## Outputs

| Name                                                                                                                  | Description                                                |
|-----------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| <a name="output_aws_autoscaling_group_arn"></a> [aws\_autoscaling\_group\_arn](#output\_aws\_autoscaling\_group\_arn) | ARN for this Auto Scaling Group                            |
| <a name="output_aws_autoscaling_group_id"></a> [aws\_autoscaling\_group\_id](#output\_aws\_autoscaling\_group\_id)    | Auto Scaling Group id.                                     |
| <a name="output_aws_launch_template_arn"></a> [aws\_launch\_template\_arn](#output\_aws\_launch\_template\_arn)       | The ARN of the launch template.                            |
| <a name="output_aws_launch_template_id"></a> [aws\_launch\_template\_id](#output\_aws\_launch\_template\_id)          | The id of the launch template.                             |
| <a name="output_custom_ami_id"></a> [custom\_ami\_id](#output\_custom\_ami\_id)                                       | The ID of the custom AMI created from the source instance. |
| <a name="output_source_instance_id"></a> [source\_instance\_id](#output\_source\_instance\_id)                        | The ID of the source instance.                             |

<!-- END_TF_DOCS -->
