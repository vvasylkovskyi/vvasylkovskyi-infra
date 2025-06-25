resource "aws_route53_zone" "main" {
  name = "vvasylkovskyi.com"
}

resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 60
  records = [var.dns_record]
}