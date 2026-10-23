terraform {
  # S3 native state locking (use_lockfile) requires Terraform 1.10+.
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      APP       = "capitec-terraform-training"
      Owner     = "Geeks4Learning"
      Developer = "marais-a"
      Purpose   = "terraform-state"
    }
  }
}