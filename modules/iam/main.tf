resource "aws_iam_user" "iam_user" {
  name = var.iam_user
}

# Create access keys for the user
resource "aws_iam_access_key" "iam_user_key" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_login_profile" "iam_user_console" {
  user = aws_iam_user.iam_user.name
}

data "aws_caller_identity" "current" {}