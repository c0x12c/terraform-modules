/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
*/
data "aws_iam_policy_document" "identity_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.principal_roles != null ? var.principal_roles : ["*"]
    }
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = [aws_ses_domain_identity.this.arn]
  }
}

/*
`aws_ses_identity_policy` attaches an IAM policy to an SES identity.
Used here to define and attach permissions to the domain identity specified in `aws_ses_domain_identity.current.arn`.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_identity_policy
*/
resource "aws_ses_identity_policy" "this" {
  count = var.enabled_ses_identity_policy ? 1 : 0

  identity = aws_ses_domain_identity.this.arn
  name     = "SES"
  policy   = data.aws_iam_policy_document.identity_policy.json
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
 */
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = concat(
      [
        aws_ses_domain_identity.this.arn,
        "${aws_ses_domain_identity.this.arn}/*",
      ],
      [for e in aws_ses_email_identity.emails : e.arn]
    )

  }
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
 */
resource "aws_iam_role_policy" "this" {
  count  = length(var.iam_role_ids)
  role   = var.iam_role_ids[count.index]
  policy = data.aws_iam_policy_document.this.json
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
*/
resource "aws_iam_policy" "this" {
  name        = "SendEmail-${aws_ses_domain_identity.this.id}"
  description = "Policy that allows request SES to send email"
  policy      = data.aws_iam_policy_document.this.json
}
