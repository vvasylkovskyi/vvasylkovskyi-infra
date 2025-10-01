variable "api_name" { type = string }

variable "ec2_public_urls" {
  type        = list(string)
  description = "List of EC2 app URLs (with ports) to proxy"
}

variable "subpaths" {
  type        = list(string)
  description = "List of subpaths for the API Gateway, e.g., ['/api', '/mcp']"
}

variable "domain_name" { type = string }
variable "acm_certificate_arn" { type = string }