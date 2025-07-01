variable "security_group" { type = string }
variable "database_name" { type = string }
variable "database_username" { type = string }
variable "database_password" { type = string }
variable "private_subnet_ids" { type = list(string) }