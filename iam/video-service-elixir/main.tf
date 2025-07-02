module "iam_user" {
  source            = "../../modules/iam"
  iam_user = var.iam_user
}

resource "aws_iam_policy" "terraform_deployer_policy" {
  name        = "elixir_s3_upload_policy"
  description = "Allow full S3 and DynamoDB access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to IAM User
resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = module.iam_user.name
  policy_arn = aws_iam_policy.terraform_deployer_policy.arn
}
