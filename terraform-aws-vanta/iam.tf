resource "aws_iam_policy" "vanta_permissions" {
  name        = var.policy_name
  description = "Custom Vanta Policy"
  policy      = data.aws_iam_policy_document.vanta_permissions.json
}

resource "aws_iam_role" "vanta_auditor" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = var.role_name
}

resource "aws_iam_role_policy_attachment" "vanta_security_audit" {
  role       = aws_iam_role.vanta_auditor.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "vanta_permissions" {
  role       = aws_iam_role.vanta_auditor.name
  policy_arn = aws_iam_policy.vanta_permissions.arn
}
