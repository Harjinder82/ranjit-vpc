# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

terraform {
  required_version = ">=0.12"
}


terraform {
  backend "s3" {
    bucket = "har-bucket-for-tfstate"
    key = "terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    dynamodb_table = "terraform-lock-table"
        
  }
}

resource "aws_dynamodb_table" "terraform-lock" {
  name = "Terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
