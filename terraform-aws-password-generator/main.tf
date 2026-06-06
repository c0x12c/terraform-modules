/*
aws_secretsmanager_random_password generates a random password.
The `password_length` is set to 32 characters and excludes punctuation for compatibility.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_random_password
*/
data "aws_secretsmanager_random_password" "random_password" {
  password_length     = var.password_length
  exclude_punctuation = true
}

/*
aws_secretsmanager_secret creates a secure secret in AWS Secrets Manager to store the password.
The secret name and tags are provided by the `secret_name` and `tags` variables.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
*/
resource "aws_secretsmanager_secret" "password" {
  name = var.secret_name
  tags = var.tags
}

/*
aws_secretsmanager_secret_version creates a new version of the secret, storing the initial password.
It references the ID of the secret created above and stores the password from `random_password`.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version
*/
resource "aws_secretsmanager_secret_version" "password_value" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = data.aws_secretsmanager_random_password.random_password.id

  // ignore any updates to the initial values above done after creation.
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
