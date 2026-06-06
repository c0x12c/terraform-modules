/**
This creates CNAME records required for SendGrid domain authentication.
These records verify that SendGrid can send emails on behalf of your domain.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
 */
resource "aws_route53_record" "cname" {
  for_each = { for idx, record in sendgrid_domain_authentication.this.dns : idx => record }

  zone_id = var.dns_zone_id

  name    = each.value.host
  records = [each.value.data]
  ttl     = 3600
  type    = upper(each.value.type)
}

/**
This creates a DMARC (Domain-based Message Authentication, Reporting, and Conformance) TXT record.
DMARC helps prevent email spoofing and phishing by defining how mail servers should handle emails that fail SPF or DKIM checks.
`p=none` means no strict enforcement (it just monitors email traffic).
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
 */
resource "aws_route53_record" "txt_dmarc" {
  zone_id = var.dns_zone_id

  name    = "_dmarc"
  records = ["v=DMARC1; p=none;"]
  ttl     = 3600
  type    = "TXT"
}

/**
This creates CNAME records for SendGrid link branding.
Link branding allows SendGrid to use your domain for tracking links in emails instead of sendgrid.net.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
 */
resource "aws_route53_record" "link_branding_records" {
  for_each = { for idx, record in sendgrid_link_branding.this.dns : idx => record }

  zone_id = var.dns_zone_id

  name    = each.value.host
  records = [each.value.data]
  ttl     = 3600
  type    = upper(each.value.type)
}
