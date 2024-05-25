locals {
  default_vars = yamldecode(file("../common/defaults.yaml"))
  config_vars  = try(yamldecode(file("../config.yaml")), {})
  project_id   = try(local.config_vars.terraform_project_id, "")
  region       = try(local.config_vars.region, local.default_vars.region)

  cloud_provider = try(
    local.config_vars.cloud_provider,
    local.default_vars.cloud_provider,
  )

  tags = try(
    local.config_vars.tags,
    local.default_vars.tags,
    {}
  )
}

resource "random_id" "this" {
  byte_length = 8
}

terraform {
  required_version = ">= 1.0.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.51.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
