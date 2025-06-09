terraform {
  backend "s3" {
    bucket         = "opswat-tfstate-BE"   # <-- REPLACE!
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "opswat-tfstate-lock"
    encrypt        = true
  }
}