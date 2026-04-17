terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
  backend "s3" {
    bucket         = "82s-tf-remote-state-dev-144"
    key            = "expense-dev-eks-rds"
    region         = "us-east-1"
    dynamodb_table = "82s-tf-remote-state-dev-144"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}