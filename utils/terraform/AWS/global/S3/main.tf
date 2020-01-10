terraform {
  backend "s3" {
    # Replace with real bucket name
    bucket = "devops-rampup-rlargot-tfstate"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"

    # Replace with dynamodb
    dynamodb_table = "devops-rampup-rlargot-tflocks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    User = var.user_tag
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  hash_key = "LockID"

  name = var.lock_table_name

  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    User = var.user_tag
  }
}