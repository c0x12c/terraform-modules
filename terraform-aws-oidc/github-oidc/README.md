# Terraform module AWS OIDC integration GitHub Actions

This [Terraform](https://www.terraform.io/) module manages OpenID Connect (OIDC) integration
between [GitHub Actions and AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

## Description

The module is strict on the claim checks to avoid that creating an OpenID connect integration opens your AWS account to
any GitHub repo. However this strictness is not taking all the risk away. Ensure you familiarize yourself with OpenID
Connect and the docs provided by GitHub and AWS. As always think about minimizing the privileges.

The module can manage the following:

- The OpenID Connect identity provider for GitHub in your AWS account (via a submodule).
- A role and assume role policy to check to check OIDC claims.

## Usages

```hcl
module "github_oidc" {
  source = "github.com/spartan-stratos/terraform-modules//aws/oidc/github-oidc?ref=v0.1.21"
  role_name       = "service-atlas"
  repository_path = "spartan/example"

  role_policy_arns = []
  aws_account_id   = "example-id"
  conditions = [
    {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:spartan/example"]
    }
  ]
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

| Name                                                                                                                                                                | Type        |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_role.github_actions_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                            | resource    |
| [aws_iam_role_policy_attachment.github_actions_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                          | data source |
| [aws_iam_policy_document.assume_role_github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                    | data source |

## Inputs

| Name                                                                                                   | Description                                                                                                                                                            | Type                                                                                                                   | Default                                                                                                               | Required |
|--------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|:--------:|
| <a name="input_additional_thumbprints"></a> [additional\_thumbprints](#input\_additional\_thumbprints) | List of additional thumbprints to add to the thumbprint list. Reference: https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/. | `list(string)`                                                                                                         | <pre>[<br/>  "6938fd4d98bab03faadb97b34396831e3780aea1",<br/>  "1c58a3a8518e8759bf075b76b750d4f2df264fcd"<br/>]</pre> |    no    |
| <a name="input_client_id_list"></a> [client\_id\_list](#input\_client\_id\_list)                       | List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided.                                            | `list(string)`                                                                                                         | <pre>[<br/>  "sts.amazonaws.com"<br/>]</pre>                                                                          |    no    |
| <a name="input_conditions"></a> [conditions](#input\_conditions)                                       | (Optional) Additonal conditions for checking the OIDC claim.                                                                                                           | <pre>list(object({<br/>    test     = string<br/>    variable = string<br/>    values   = list(string)<br/>  }))</pre> | `[]`                                                                                                                  |    no    |
| <a name="input_create_provider"></a> [create\_provider](#input\_create\_provider)                      | Whether to create a provider resource for migration purpose on existing provider.                                                                                      | `bool`                                                                                                                 | `false`                                                                                                               |    no    |
| <a name="input_repository_path"></a> [repository\_path](#input\_repository\_path)                      | The path to the repository (organization/repo\_name).                                                                                                                  | `string`                                                                                                               | n/a                                                                                                                   |   yes    |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name)                                        | The name of the role to be created.                                                                                                                                    | `string`                                                                                                               | n/a                                                                                                                   |   yes    |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix)                 | The name of the role to be created.                                                                                                                                    | `string`                                                                                                               | `""`                                                                                                                  |    no    |
| <a name="input_role_policy_arns"></a> [role\_policy\_arns](#input\_role\_policy\_arns)                 | List of ARNs of IAM policies to attach to IAM role                                                                                                                     | `list(string)`                                                                                                         | `[]`                                                                                                                  |    no    |
| <a name="input_url"></a> [url](#input\_url)                                                            | The URL of the identity provider. Corresponds to the iss claim.                                                                                                        | `string`                                                                                                               | `"https://token.actions.githubusercontent.com"`                                                                       |    no    |

## Outputs

| Name                                                                       | Description                                                     |
|----------------------------------------------------------------------------|-----------------------------------------------------------------|
| <a name="output_provider_arn"></a> [provider\_arn](#output\_provider\_arn) | The ARN assigned by AWS for this provider.                      |
| <a name="output_provider_url"></a> [provider\_url](#output\_provider\_url) | The URL of the identity provider. Corresponds to the iss claim. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn)             | The ARN of the IAM role used for GitHub Actions operations.     |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id)                | The ID of the IAM role used for GitHub Actions operations.      |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name)          | The Name of the IAM role used for GitHub Actions operations.    |

<!-- END_TF_DOCS -->