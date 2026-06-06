locals {
  dd_source  = "lambda_outgoing_email_logs"
  dd_service = "ses_outgoing_email_logs"
  name       = "ses_${var.name}_outgoing_email_logs"
}
