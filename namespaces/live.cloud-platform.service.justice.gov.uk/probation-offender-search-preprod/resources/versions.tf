
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.68.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2" # Pinned version due to bcrypt bug in 3.4.0+. See https://github.com/hashicorp/terraform-provider-random/issues/307
    }
  }
}
