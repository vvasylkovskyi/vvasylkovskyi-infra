
output "access_key_id" {
  value = module.iam_user.access_key_id
}

output "secret_access_key" {
  value     = module.iam_user.secret_access_key
  sensitive = true
}

output "console_username" {
  value     = module.iam_user.console_username
  sensitive = true
}

output "console_password" {
  value     = module.iam_user.console_password
  sensitive = true
}

output "account_id" {
  value       = module.iam_user.account_id
}