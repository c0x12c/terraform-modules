/*
This will overwrite the default key policy resource
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
*/
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.principal_roles != null ? var.principal_roles : ["*"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:PutKeyPolicy",
    ]
    resources = [aws_kms_key.this.arn]
  }

  dynamic "statement" {
    for_each = var.additional_statements

    content {
      effect = statement.value.effect
      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }

      actions = statement.value.actions

      resources = statement.value.resources

      dynamic "condition" {
        for_each = lookup(statement.value, "condition", null) != null ? [statement.value.condition] : []

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy
*/
resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = data.aws_iam_policy_document.this.json
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
*/
data "aws_iam_policy_document" "encrypt_decrypt" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.this.arn]
  }
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
*/
resource "aws_iam_policy" "this" {
  for_each    = toset(var.alias_name)
  name        = "KmsEncryptDecrypt-${each.value}"
  description = "Policy that allows encrypt and decrypt data with the provided encryption KMS key."
  policy      = data.aws_iam_policy_document.encrypt_decrypt.json
}
