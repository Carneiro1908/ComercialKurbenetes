terraform {
  required_version = ">= 1.5.0"
  
  # Commercial Remote Backend Configuration
  backend "s3" {
    bucket         = "comercial-k8s-protected-storage-2026"
    key            = "infrastructure/terraform.tfstate" # Path inside the bucket
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "comercial-k8s-terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}