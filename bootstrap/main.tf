locals {
  default_vars = yamldecode(file("../common/defaults.yaml"))
  config_vars  = try(yamldecode(file("../config.yaml")), {})

  cloud_provider = try(
    local.config_vars.cloud_provider,
    local.default_vars.cloud_provider,
    "aws",
  )
  region = try(
    local.config_vars.metadata.region,
    local.config_vars.region,
    local.default_vars.metadata.region,
    "us-west-2"
  )
  tags = try(
    local.config_vars.tags,
    local.default_vars.tags,
    {}
  )
}

output "terraform_state_bucket" {
  value = join(",", values(aws_s3_bucket.this)[*].id)
}

output "region" {
  value = local.region
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
