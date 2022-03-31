terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "sym-tfstate-017453300286"
    key            = "sandbox/terraform.tfstate"
    dynamodb_table = "sym-tfstate-017453300286-lock"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}
