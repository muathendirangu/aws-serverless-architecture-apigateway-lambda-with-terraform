

resource "random_id" "unique_suffix" {
  byte_length = 2
}

locals {
  app_id = "${lower(var.app_name)}-${lower(var.app_env)}-${random_id.unique_suffix.hex}"
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "build/bin/app"
  output_path = "build/bin/app.zip"
}

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_storage_bucket.id
  key    = "app.zip"
  source = data.archive_file.lambda_zip.output_path
  etag = filemd5(data.archive_file.lambda_zip.output_path)
}


terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.34.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  access_key = "your_access_key_here"
  secret_key = "your_secret_key_here"
}

resource "aws_vpc" "bits" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "bits-vpc"
  }
}

resource "aws_subnet" "bits" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.bits.id
  tags = {
    Name = "bits-subnet"
  }
}


resource "aws_security_group" "bits" {
  vpc_id = aws_vpc.bits.id
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

