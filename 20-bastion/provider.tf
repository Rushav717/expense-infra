terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
    backend "s3" {
    bucket         = "82s-tf-remote-state-dev-144"
    key            = "expense-dev-eks-bastion"
    region         = "us-east-1"
    dynamodb_table = "82s-tf-remote-state-dev-144"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}