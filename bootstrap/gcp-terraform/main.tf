locals {
  default_vars = yamldecode(file("../../common/defaults-gcp.yaml"))
  config_vars  = try(yamldecode(file("../../config.yaml")), {})
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
