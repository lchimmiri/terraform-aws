terraform {
  backend "s3" {
    bucket = "terraform-aws-bkt"
    region = "us-east-1"
    key    = "terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
