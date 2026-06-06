# OIDC Provider

Creates an IAM identity provider for Custom OIDC.

Generalized from [(Jenkins OIDC)](../jenkins-oidc) and [(GitHub OIDC)](../github-oidc) modules.

## Usage

```hcl
module "provider" {
  source    = "github.com/spartan-stratos/terraform-modules//aws/oidc/provider?ref=v0.1.21"

  url                    = "https://token.actions.githubusercontent.com"
  client_id_list         = ["sts.amazonaws.com"]
  additional_thumbprints = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.75  |
| <a name="requirement_tls"></a> [tls](#requirement\_tls)                   | >= 4.0.6 |

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75  |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.6 |

## Modules

No modules.

## Resources

| Name                                                                                                                                               | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider)    | resource    |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate)                                 | data source |

## Inputs

| Name                                                                                                   | Description                                                                                                                | Type           | Default                                      | Required |
|--------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|----------------|----------------------------------------------|:--------:|
| <a name="input_additional_thumbprints"></a> [additional\_thumbprints](#input\_additional\_thumbprints) | List of additional thumbprints to add to the thumbprint list.                                                              | `list(string)` | `[]`                                         |    no    |
| <a name="input_client_id_list"></a> [client\_id\_list](#input\_client\_id\_list)                       | List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided | `list(string)` | <pre>[<br/>  "sts.amazonaws.com"<br/>]</pre> |    no    |
| <a name="input_create_provider"></a> [create\_provider](#input\_create\_provider)                      | Whether to create a provider resource for migration purpose on existing provider.                                          | `bool`         | `false`                                      |    no    |
| <a name="input_url"></a> [url](#input\_url)                                                            | The URL of the identity provider. Corresponds to the iss claim                                                             | `string`       | n/a                                          |   yes    |

## Outputs

| Name                                          | Description                                                    |
|-----------------------------------------------|----------------------------------------------------------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN assigned by AWS for this provider                      |
| <a name="output_url"></a> [url](#output\_url) | The URL of the identity provider. Corresponds to the iss claim |

<!-- END_TF_DOCS -->