/*
aws_amplify_app provides an Amplify App resource, a fullstack serverless app hosted on the AWS Amplify Console.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app
*/
resource "aws_amplify_app" "this" {
  name       = var.name
  repository = var.repository

  access_token = var.github_token

  build_spec = templatefile(local.build_spec, {
    application_root         = local.normalized_root
    base_artifacts_directory = var.base_artifacts_directory
    build_command            = var.build_command
    install_command          = var.install_command
  })

  dynamic "custom_rule" {
    for_each = local.custom_redirect_rules

    content {
      source = custom_rule.value.source
      target = custom_rule.value.target
      status = custom_rule.value.status
    }
  }

  platform              = var.web_platform
  iam_service_role_arn  = aws_iam_role.amplify_backend.arn
  environment_variables = var.build_variables

  custom_headers = local.custom_headers

  lifecycle {
    ignore_changes = [
      access_token
    ]
  }
}

/*
aws_amplify_backend_environment provides an Amplify Backend Environment resource.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_backend_environment
*/
resource "aws_amplify_backend_environment" "this" {
  count = var.enable_backend ? 1 : 0

  app_id           = aws_amplify_app.this.id
  environment_name = "backend"
}

/*
aws_amplify_branch provides an Amplify Branch resource.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_branch
*/
resource "aws_amplify_branch" "this" {
  app_id      = aws_amplify_app.this.id
  branch_name = var.deploy_branch_name

  stage                   = var.environment == "prod" ? "PRODUCTION" : "DEVELOPMENT"
  backend_environment_arn = var.enable_backend ? aws_amplify_backend_environment.this[0].arn : null

  enable_auto_build = var.enable_auto_build
  framework         = var.framework
}

/*
aws_amplify_domain_association provides an Amplify Domain Association resource.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_domain_association
*/
resource "aws_amplify_domain_association" "this" {
  app_id                = aws_amplify_app.this.id
  domain_name           = local.domain_name
  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.this.branch_name
    prefix      = ""
  }

  sub_domain {
    branch_name = aws_amplify_branch.this.branch_name
    prefix      = "www"
  }
}

/*
aws_amplify_webhook provides an Amplify Webhook resource.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_webhook
*/
resource "aws_amplify_webhook" "main" {
  count = var.enable_backend ? 0 : 1

  app_id      = aws_amplify_app.this.id
  branch_name = aws_amplify_branch.this.branch_name
  description = "trigger-building"

  # NOTE: We trigger the webhook via local-exec so as to kick off the first build on creation of Amplify App.
  provisioner "local-exec" {
    command = "curl -X POST -d {} '${aws_amplify_webhook.main[0].url}&operation=startbuild' -H 'Content-Type:application/json'"
  }
}
