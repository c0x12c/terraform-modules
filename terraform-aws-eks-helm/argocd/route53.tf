module "route53" {
  source   = "../../route53"
  dns_zone = var.domain_name
}

resource "aws_route53_record" "this" {
  count = var.create_route53_record ? 1 : 0

  name    = var.sub_domain
  type    = "A"
  zone_id = module.route53.r53_main_zone_id

  alias {
    zone_id                = var.alb_zone_id
    name                   = var.alb_cname
    evaluate_target_health = true
  }
}
