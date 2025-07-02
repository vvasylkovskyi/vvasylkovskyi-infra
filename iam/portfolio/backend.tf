resource "aws_s3_bucket" "terraform_state" {
  bucket = "portfolio-iam"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "portfolio-iam"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "portfolio-iam"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "portfolio-iam"
  }
}
