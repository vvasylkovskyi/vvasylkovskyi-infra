output "security_group_ec2" { value = aws_security_group.ec2.id }
output "security_group_alb" { value = aws_security_group.alb.id }