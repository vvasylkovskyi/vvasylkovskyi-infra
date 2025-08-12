variable "clerk_cname_records" {
  type = map(string)
  default = {
    clerk          = "frontend-api.clerk.services"
    accounts       = "accounts.clerk.services"
    clkmail        = "mail.6dzf3jivhtew.clerk.services"
    "clk._domainkey"  = "dkim1.6dzf3jivhtew.clerk.services"
    "clk2._domainkey" = "dkim2.6dzf3jivhtew.clerk.services"
  }
}

resource "aws_route53_record" "clerk_cname" {
  for_each = var.clerk_cname_records

  zone_id = var.route53_zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}