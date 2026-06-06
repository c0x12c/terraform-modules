# AWS Password Policy module

This module configures an IAM account password policy in AWS, enforcing security requirements such as minimum
password length, required character types, and user password management capabilities.

## Usage

### Create an password policy

```hcl
module "password_policy" {
  source = "github.com/spartan-stratos/terraform-modules//aws/password-policy?ref=v0.1.52"

  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
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

| Name                                                                                                                                            | Type     |
|-------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |

## Inputs

| Name                                                                                                                                 | Description                                                          | Type     | Default | Required |
|--------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|----------|---------|:--------:|
| <a name="input_allow_users_to_change_password"></a> [allow\_users\_to\_change\_password](#input\_allow\_users\_to\_change\_password) | Indicates whether users are allowed to change their own passwords.   | `bool`   | `true`  |    no    |
| <a name="input_minimum_password_length"></a> [minimum\_password\_length](#input\_minimum\_password\_length)                          | The minimum number of characters required for a password.            | `number` | `8`     |    no    |
| <a name="input_require_lowercase_characters"></a> [require\_lowercase\_characters](#input\_require\_lowercase\_characters)           | Specifies if a password must contain at least one lowercase letter.  | `bool`   | `true`  |    no    |
| <a name="input_require_numbers"></a> [require\_numbers](#input\_require\_numbers)                                                    | Specifies if a password must contain at least one numeric character. | `bool`   | `true`  |    no    |
| <a name="input_require_symbols"></a> [require\_symbols](#input\_require\_symbols)                                                    | Specifies if a password must contain at least one special symbol.    | `bool`   | `true`  |    no    |
| <a name="input_require_uppercase_characters"></a> [require\_uppercase\_characters](#input\_require\_uppercase\_characters)           | Specifies if a password must contain at least one uppercase letter.  | `bool`   | `true`  |    no    |

## Outputs

| Name                                                                                   | Description                                                           |
|----------------------------------------------------------------------------------------|-----------------------------------------------------------------------|
| <a name="output_expire_passwords"></a> [expire\_passwords](#output\_expire\_passwords) | Indicates whether passwords expire as per the account password policy |

<!-- END_TF_DOCS -->