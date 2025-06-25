output "dns_record" {
  value       = aws_route53_record.record.fqdn
  description = "The FQDN of the www Route53 record"
}