terraform {
    required_providers {
      cloudflare = {
        source  = "cloudflare/cloudflare"
        version = "~> 5.0"
      }
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
  }