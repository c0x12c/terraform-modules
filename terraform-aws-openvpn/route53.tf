/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
*/
data "aws_route53_zone" "domain" {
  name = var.domain_name
}

/*
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
 */
resource "aws_route53_record" "vpn" {
  zone_id = data.aws_route53_zone.domain.zone_id

  name = local.openvpn_fqdn
  type = "A"
  ttl  = "60"

  records = [aws_eip.this.public_ip]
}
