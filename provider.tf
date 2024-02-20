provider "aws" {
  region     = var.region
  allowed_account_ids = ["975050315907"]
  
}

terraform {
  backend "s3" {
    bucket         = "terraform-state1234"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locking-table"
  }
}