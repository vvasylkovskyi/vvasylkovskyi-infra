resource "aws_route53_zone" "main" {
  name = var.route53_zone_id
}

resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.aws_lb_dns_name
    zone_id                = var.aws_lb_zone_id
    evaluate_target_health = true
  }
}
