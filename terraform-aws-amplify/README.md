# AWS Amplify app Terraform module

Terraform module to provision AWS Amplify apps, backend environments, branches, domain associations.

Depends on the app types (SSG or SSR), you will have to manually change the buildspec as
this [guideline](https://docs.aws.amazon.com/amplify/latest/userguide/deploy-nextjs-app.html)

## Usage

### Next.js app

```hcl
module "website" {
  source  = "github.com/c0x12c/terraform-aws-amplify?ref=v0.1.0"

  dns_zone         = "example.com"
  environment      = "dev"
  repository       = "https://github.com/example-org/example-repo"
  application_root = "./"
  build_variables = {
    NEXT_PUBLIC_DOMAIN = "https://test.example.com"
    NEXT_PUBLIC_ENV    = "dev"
  }
  github_token             = "example"
  deploy_branch_name       = "master"
  sub_domain               = "test"
  name                     = "example"
  install_command          = "yarn install"
  build_command            = "yarn build"
  base_artifacts_directory = ".next"

  # Optional: Configure custom HTTP headers
  custom_headers = [
    {
      pattern = "**/*"
      headers = [
        {
          key   = "Strict-Transport-Security"
          value = "max-age=63072000; includeSubDomains; preload"
        },
        {
          key   = "X-Content-Type-Options"
          value = "nosniff"
        }
      ]
    }
  ]
}

```

## Examples

- [Next.js App with Custom Headers Example](./examples/nextjs-app/) - Demonstrates security headers and cache control configuration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.5.0, < 6.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_amplify_app.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app) | resource |
| [aws_amplify_backend_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_backend_environment) | resource |
| [aws_amplify_branch.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_branch) | resource |
| [aws_amplify_domain_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_domain_association) | resource |
| [aws_amplify_webhook.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_webhook) | resource |
| [aws_cloudwatch_event_rule.amplify_build_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.lambda_amplify_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.amplify_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.amplify_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_amplify_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_logs_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.amplify_notifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.amplify_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_root"></a> [application\_root](#input\_application\_root) | The root directory for building application | `string` | n/a | yes |
| <a name="input_base_artifacts_directory"></a> [base\_artifacts\_directory](#input\_base\_artifacts\_directory) | Base directory that stores build artifacts | `string` | `".next"` | no |
| <a name="input_build_command"></a> [build\_command](#input\_build\_command) | The build command to execute JS scripts | `string` | `"yarn build"` | no |
| <a name="input_build_variables"></a> [build\_variables](#input\_build\_variables) | Map of environment variables for building app | `map(string)` | n/a | yes |
| <a name="input_custom_headers"></a> [custom\_headers](#input\_custom\_headers) | Custom HTTP headers for the Amplify app | <pre>list(object({<br/>    pattern = string<br/>    headers = list(object({<br/>      key   = string<br/>      value = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_redirect_rules"></a> [custom\_redirect\_rules](#input\_custom\_redirect\_rules) | Custom redirect rules for redirecting requests to Amplify app | <pre>list(object({<br/>    source = string<br/>    status = string<br/>    target = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "source": "/<*>",<br/>    "status": "404",<br/>    "target": "/index.html"<br/>  }<br/>]</pre> | no |
| <a name="input_deploy_branch_name"></a> [deploy\_branch\_name](#input\_deploy\_branch\_name) | The branch name to deploy the source code | `string` | n/a | yes |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | DNS zone for creating domain | `string` | n/a | yes |
| <a name="input_enable_auto_build"></a> [enable\_auto\_build](#input\_enable\_auto\_build) | To enable auto build for deployment branch | `bool` | `true` | no |
| <a name="input_enable_backend"></a> [enable\_backend](#input\_enable\_backend) | To enable aws\_amplify\_backend\_environment | `bool` | `true` | no |
| <a name="input_enable_redirect_to_root"></a> [enable\_redirect\_to\_root](#input\_enable\_redirect\_to\_root) | To enable redirect to the root | `bool` | `false` | no |
| <a name="input_enabled_notification"></a> [enabled\_notification](#input\_enabled\_notification) | To enable the webhook notification to slack, which will create resources relating lambda function and eventbridge to semd a message | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for the Amplify app | `string` | n/a | yes |
| <a name="input_framework"></a> [framework](#input\_framework) | Optional framework for the branch | `string` | `null` | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | Github access token for authorizing with Github | `string` | n/a | yes |
| <a name="input_install_command"></a> [install\_command](#input\_install\_command) | The install command to install packages | `string` | `"yarn install"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name for the Amplify app | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Source repository for Amplify app | `string` | n/a | yes |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | To define webhook url for notifying statuses to Slack | `string` | `null` | no |
| <a name="input_sub_domain"></a> [sub\_domain](#input\_sub\_domain) | Subdomain for the Amplify app | `string` | `""` | no |
| <a name="input_web_platform"></a> [web\_platform](#input\_web\_platform) | Amplify App platform for building web app | `string` | `"WEB"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amplify_app_backend_role_arn"></a> [amplify\_app\_backend\_role\_arn](#output\_amplify\_app\_backend\_role\_arn) | Created app backend role arn |
| <a name="output_amplify_app_backend_role_name"></a> [amplify\_app\_backend\_role\_name](#output\_amplify\_app\_backend\_role\_name) | Created app backend role name |
| <a name="output_arn"></a> [arn](#output\_arn) | Amplify App ARN |
| <a name="output_backend_environment_arn"></a> [backend\_environment\_arn](#output\_backend\_environment\_arn) | Created backend environment arn |
| <a name="output_backend_environment_name"></a> [backend\_environment\_name](#output\_backend\_environment\_name) | Created backend environment name |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Created domain name |
| <a name="output_id"></a> [id](#output\_id) | Amplify App ID |
| <a name="output_name"></a> [name](#output\_name) | Amplify App name |
| <a name="output_webhook_url"></a> [webhook\_url](#output\_webhook\_url) | To get the webhook url of amplify |
<!-- END_TF_DOCS -->
