terraform {
  required_version = ">= 1.0.3, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
