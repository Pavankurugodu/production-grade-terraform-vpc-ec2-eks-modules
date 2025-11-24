terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    /*tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }*/
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
