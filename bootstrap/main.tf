locals {
  default_vars = yamldecode(file("../common/defaults.yaml"))
  config_vars  = try(yamldecode(file("../config.yaml")), {})

  cloud_provider = try(
    local.config_vars.cloud_provider,
    local.default_vars.cloud_provider,
  )
  region = try(
    local.config_vars.metadata.region,
    local.default_vars.region,
  )
  tags = try(
    local.config_vars.tags,
    local.default_vars.tags,
    {}
  )
}

terraform {
  required_version = ">= 1.0.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
