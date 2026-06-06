/*
aws_route53_zone data source retrieves information about an existing Route 53 DNS zone.
Used to avoid creating a new zone if `create_new` is set to `false`.
Accepts the DNS zone name through the `dns_zone` variable.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
*/
data "aws_route53_zone" "dns_zone" {
  count = var.create_new ? 0 : 1

  name = "${var.dns_zone}."
}

/*
aws_route53_zone dns_zone creates a new Route 53 DNS zone if `create_new` is set to `true`.
This block provisions the new zone with the name specified in the `dns_zone` variable.
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
*/
resource "aws_route53_zone" "dns_zone" {
  count = var.create_new ? 1 : 0

  name = var.dns_zone
}
