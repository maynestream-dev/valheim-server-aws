terraform {
  required_version = "~> 1.5.7"

  backend "s3" {
    bucket = "valheim-server-tf"
    key    = "valheim-server/prod/terraform.tfstate"
    region = "eu-north-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}
