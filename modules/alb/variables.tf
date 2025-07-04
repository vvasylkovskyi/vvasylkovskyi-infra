variable "acm_certificate_arn" { type = string }
variable "aws_acm_certificate_cert" {
  type = object({
    arn = string
    id  = string
  })
}
variable "vpc_id" { type = string }
variable "subnets" { type = list(string) }
variable "security_group" { type = string }
variable "ec2_instance_id" { type = string }
variable "alb_name" { type = string }
