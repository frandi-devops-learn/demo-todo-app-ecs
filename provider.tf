terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "frandi"
}

locals {
  common_tags = {
    Project     = "demo-sms"
    Managedby   = "Terraform"
    Owner       = "DevOps Team"
    Environment = "UAT"
  }
}