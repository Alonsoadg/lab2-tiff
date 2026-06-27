terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto 
  # backend "s3" {
  #   bucket         = "ulagos-terraform-state-tu-grupo"
  #   key            = "proyecto/hito1/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-lock-table"
  # }
}

provider "aws" {
  region = var.region
}