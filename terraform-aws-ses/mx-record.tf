/**
Adds an MX (Mail Exchange) record to your DNS zone, directing email traffic for the domain to the specified email receiving endpoint.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
 */
resource "aws_route53_record" "mx" {
  count = var.publish_mx_record ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].id
  name    = ""
  type    = "MX"
  ttl     = 60
  records = ["10 ${var.email_receiving_endpoint}"]
}
