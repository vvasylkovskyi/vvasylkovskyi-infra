resource "aws_s3_bucket" "terraform_state" {
  bucket = var.backend_bucket
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.lock_table
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "vvasylkovskyi-backend-api-terraform-state-backend"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "backend_api_terraform_state"
  }
}
