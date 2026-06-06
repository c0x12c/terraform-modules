/**
This resource enables DomainKeys Identified Mail (DKIM) signing for the domain
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim
 */
resource "aws_ses_domain_dkim" "this" {
  count = var.publish_dkim_record ? 1 : 0

  domain = aws_ses_domain_identity.this.domain
}

/*
Creates a DNS TXT record for DKIM verification in Amazon SES.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
*/
resource "aws_route53_record" "dkim" {
  count = var.publish_dkim_record ? 3 : 0

  zone_id = data.aws_route53_zone.this[0].id
  name    = "${aws_ses_domain_dkim.this[0].dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.this[0].dkim_tokens[count.index]}.dkim.amazonses.com"]
}
