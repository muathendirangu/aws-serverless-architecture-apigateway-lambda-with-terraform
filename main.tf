variable "app_name" {
    description = "application name"
    default = "golang-serverless-api"
}

variable "app_env" {
  default = "dev"
  description = "application environment variable"
}

variable "app_runtime" {
  default = "provided.al2"
  description = "lambda runtime specification"
}

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

output "api_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}

terraform {
  required_providers {
    aws = {
        source = "harshicop/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1a"
  access_key = "your_access_key_here"
  secret_key = "your_secret_key_here"
}

resource "bits_vpc" "bits" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "bits-vpc"
  }
}

resource "bits_subnet" "bits" {
  cidr_block = "10.0.2.0/24"
  vpc_id = bits_vpc.bits.id
  tags = {
    Name = "bits-subnet"
  }
}


resource "bits_sg" "bits" {
  vpc_id = bits_vpc.bits.id
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

