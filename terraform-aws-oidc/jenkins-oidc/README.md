# Terraform module AWS OIDC integration Jenkins

This [Terraform](https://www.terraform.io/) module manages OpenID Connect (OIDC) integration
between [Jenkins and AWS](https://plugins.jenkins.io/oidc-provider/).

## Description

The module is strict on the claim checks to avoid that creating an OpenID connect integration opens your AWS account to
Jenkins. However this strictness is not taking all the risk away. Ensure you familiarize yourself with OpenID Connect
and the docs provided by Jenkins and AWS. As always think about minimizing the privileges.

The module can manage the following:

- The OpenID Connect identity provider for Jenkins in your AWS account (via a submodule).
- A role and assume role policy to check to check OIDC claims.

## Usages

```hcl
module "jenkins_oidc" {
  source = "github.com/spartan-stratos/terraform-modules//aws/oidc/jenkins-oidc?ref=v0.1.21"

  role_name = "jenkins"
  url       = "https://jenkins.example.com/oidc"
}
```

## Examples

Check out the [example](examples/default/README.md) for a full example of using the module.

## Examples

- [Example complete](./examples/complete/)

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75  |
| <a name="requirement_tls"></a> [tls](#requirement\_tls)                   | >= 4.0.6 |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

| Name                                                         | Source      | Version |
|--------------------------------------------------------------|-------------|---------|
| <a name="module_provider"></a> [provider](#module\_provider) | ../provider | n/a     |

## Resources

| Name                                                                                                                                          | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_policy.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                 | resource    |
| [aws_iam_role.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                     | resource    |
| [aws_iam_role_policy_attachment.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)     | data source |
| [aws_iam_policy_document.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |

## Inputs

| Name                                                                                                                         | Description                                                                                                                 | Type                                                                                                                            | Default                                      | Required |
|------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------|:--------:|
| <a name="input_additional_thumbprints"></a> [additional\_thumbprints](#input\_additional\_thumbprints)                       | List of additional thumbprints to add to the thumbprint list. Reference: https://plugins.jenkins.io/oidc-provider/.         | `list(string)`                                                                                                                  | `[]`                                         |    no    |
| <a name="input_client_id_list"></a> [client\_id\_list](#input\_client\_id\_list)                                             | List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided. | `list(string)`                                                                                                                  | <pre>[<br/>  "sts.amazonaws.com"<br/>]</pre> |    no    |
| <a name="input_create_provider"></a> [create\_provider](#input\_create\_provider)                                            | Whether to create a provider resource for migration purpose on existing provider.                                           | `bool`                                                                                                                          | `false`                                      |    no    |
| <a name="input_custom_oidc_policy_statement"></a> [custom\_oidc\_policy\_statement](#input\_custom\_oidc\_policy\_statement) | Whether to create a custom oidc policy statement                                                                            | <pre>list(object({<br/>    effect    = string<br/>    actions   = list(string)<br/>    resources = list(string)<br/>  }))</pre> | `[]`                                         |    no    |
| <a name="input_oidc_policy_description"></a> [oidc\_policy\_description](#input\_oidc\_policy\_description)                  | Whether to define description for jenkins oidc policy                                                                       | `string`                                                                                                                        | `null`                                       |    no    |
| <a name="input_oidc_policy_name"></a> [oidc\_policy\_name](#input\_oidc\_policy\_name)                                       | Whether to overwrite the default jenkins oidc policy name                                                                   | `string`                                                                                                                        | `null`                                       |    no    |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name)                                                              | The name of the role to be created.                                                                                         | `string`                                                                                                                        | n/a                                          |   yes    |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix)                                       | The name of the role to be created.                                                                                         | `string`                                                                                                                        | `""`                                         |    no    |
| <a name="input_url"></a> [url](#input\_url)                                                                                  | The URL of the identity provider. Corresponds to the iss claim.                                                             | `string`                                                                                                                        | n/a                                          |   yes    |

## Outputs

| Name                                                                       | Description                                                     |
|----------------------------------------------------------------------------|-----------------------------------------------------------------|
| <a name="output_provider_arn"></a> [provider\_arn](#output\_provider\_arn) | The ARN assigned by AWS for this provider.                      |
| <a name="output_provider_url"></a> [provider\_url](#output\_provider\_url) | The URL of the identity provider. Corresponds to the iss claim. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn)             | The role ARN of Jenkins OIDC.                                   |

<!-- END_TF_DOCS -->