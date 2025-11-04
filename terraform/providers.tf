terraform {

  backend "s3" {
    bucket = "solar-system-app-bucket-hossam-98787676"
    key    = "terraform/state/project2.tfstate"
    region = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.18.0"
    }
  }
}

provider "aws" {
  region = var.region
}

