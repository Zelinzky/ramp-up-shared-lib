terraform {
  backend "s3" {
    # Replace with real bucket name
    bucket = "terraform-up-runing-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"

    # Replace with dynamodb
    dynamodb_table = "terraform-up-running-locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-runing-state"

  # Prevents accidental deletion of the bucket
  lifecycle {
    prevent_destroy = true
  }

  # Enables versioning so we have the full history of the files
  versioning {
    enabled = true
  }

  # Enables server side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-up-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}