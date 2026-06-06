/* 
aws_acm_certificate allows requesting and management of certificates from the Amazon Certificate Manager.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
*/
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

/* 
aws_route53_record provides a Route53 record resource to request a DNS validated certificate.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
*/
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
    if var.zone_id != null
  }

  zone_id         = var.zone_id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type

  depends_on = [aws_acm_certificate.this]
}

/*
aws_acm_certificate_validation represents a successful validation of an ACM certificate in concert with other resources.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
*/
resource "aws_acm_certificate_validation" "this" {
  count = (var.wait_for_validation && var.zone_id != null) ? 1 : 0

  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]

  timeouts {
    create = var.validation_timeout
  }
}
