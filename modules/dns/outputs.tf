output "dns_record" {
  value       = aws_route53_record.record.fqdn
}

output "aws_route53_zone_name" {
    value = aws_route53_zone.main.name
}

output "aws_route53_zone_id" {
    value = aws_route53_zone.main.id
}