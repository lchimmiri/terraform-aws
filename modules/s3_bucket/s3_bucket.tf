terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name
}