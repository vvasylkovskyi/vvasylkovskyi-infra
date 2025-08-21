output "security_group_ec2" { value = aws_security_group.ec2.id }
output "security_group_alb_http" { value = aws_security_group.alb_http.id }
output "security_group_alb_https" { value = aws_security_group.alb_https.id }
output "security_group_rds" { value = aws_security_group.rds.id }

