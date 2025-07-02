
output "access_key_id" {
  value = aws_iam_access_key.iam_user_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.iam_user_key.secret
  sensitive = true
}

output "console_username" {
  value     = aws_iam_user.iam_user.name
  sensitive = true
  description = "Initial console username for the IAM user"
}

output "console_password" {
  value     = aws_iam_user_login_profile.iam_user_console.password
  sensitive = true
  description = "Initial console password for the IAM user"
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID"
}

output "name" {
    value = aws_iam_user.iam_user.name
    description = "IAM User Name"
}