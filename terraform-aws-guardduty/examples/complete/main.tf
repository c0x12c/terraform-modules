module "guardduty" {
  source = "../.."

  name                          = "example"
  enabled_guardduty             = true
  enabled_guardduty_eks_audit   = true
  enabled_guardduty_s3_scanning = true
  enabled_email_notification    = true
}
