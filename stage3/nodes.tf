locals {
  cnode_v1_namespace          = "ext-nodes-m1"
  cnode_v1_default_base_image = "ghcr.io/blinklabs-io/cardano-node"
  cnode_v1_default_image_tag  = "9.1.0-2"
  cnode_v1_edge_base_image    = "ghcr.io/demeter-run/cardano-node-edge"
  cnode_v1_edge_image_tag     = "be248be99fa238ebb9c2f72e6042739bf02263d6"
  cnode_v1_v135_base_image    = "ghcr.io/blinklabs-io/cardano-node"
  cnode_v1_v135_image_tag     = "1.35.7-8"
  cnode_v1_api_key_salt       = coalesce(var.cnode_v1_api_key_salt, "this is a random generated key and must be shared...")
}

module "ext_cardano_node_crds" {
  source   = "git::https://github.com/blinklabs-io/demeter-ext-cardano-node.git//bootstrap/crds?ref=feat/gcp-cloud-provider"
  for_each = toset([for n in toset(["global"]) : n if var.enable_cardano_node])
}

# module "ext_cardano_node_configs" {
#   source    = "git::https://github.com/blinklabs-io/demeter-ext-cardano-node.git//bootstrap/configs?ref=feat/gcp-cloud-provider"
#   for_each  = toset([for n in toset(["m1"]) : n if var.enable_cardano_node])
#   namespace = local.cnode_v1_namespace
# }

module "ext_cardano_node" {
  source                          = "git::https://github.com/blinklabs-io/demeter-ext-cardano-node.git//bootstrap?ref=feat/gcp-cloud-provider"
  for_each                        = toset([for n in toset(["m1"]) : n if var.enable_cardano_node])
  namespace                       = local.cnode_v1_namespace
  cloud_provider                  = var.cloud_provider
  dns_zone                        = "dmtr.host"
  extension_name                  = "cnode-${each.key}"
  operator_image_tag              = "9f24ebfe1ca56351fa44ab47e5a3fdb815d0f213"
  proxy_blue_image_tag            = "9f24ebfe1ca56351fa44ab47e5a3fdb815d0f213"
  proxy_blue_replicas             = 2
  proxy_blue_instances_namespace  = local.cnode_v1_namespace
  proxy_blue_healthcheck_port     = 31789
  proxy_green_image_tag           = "9f24ebfe1ca56351fa44ab47e5a3fdb815d0f213"
  proxy_green_replicas            = 2
  proxy_green_instances_namespace = local.cnode_v1_namespace
  proxy_green_healthcheck_port    = 32171
  api_key_salt                    = local.cnode_v1_api_key_salt
  dcu_per_second = {
    mainnet          = "1"
    preprod          = "1"
    preview          = "1"
    sanchonet        = "1"
    "vector-testnet" = "1"
  }
  metrics_delay = 60
  instances = {

    # "mainnet-stable-v6g" = {
    #   node_image    = local.cnode_v1_default_base_image
    #   image_tag     = local.cnode_v1_default_image_tag
    #   network       = "mainnet"
    #   salt          = "v6g"
    #   release       = "stable"
    #   magic         = 764824073
    #   topology_zone = "us-central1-a"
    #   node_resources = {
    #     limits = {
    #       "memory" = "16Gi"
    #       "cpu"    = "8"
    #     }
    #     requests = {
    #       "memory" = "16Gi"
    #       "cpu"    = "2"
    #     }
    #   }
    #   storage_size       = "200Gi"
    #   storage_class_name = "gp"
    #   node_version       = local.cnode_v1_default_image_tag
    #   replicas           = 2
    #   restore            = true
    # }

    "preview-stage-v6g" = {
      node_image    = local.cnode_v1_default_base_image
      image_tag     = local.cnode_v1_default_image_tag
      network       = "preview"
      salt          = "v6g"
      release       = "stable"
      magic         = 2
      topology_zone = "us-central1-b"
      node_resources = {
        limits = {
          "memory" = "3Gi"
          "cpu"    = "8"
        }
        requests = {
          "memory" = "3Gi"
          "cpu"    = "100m"
        }
      }
      storage_class_name = "gp"
      node_version       = local.cnode_v1_default_image_tag
      replicas           = 2
      restore            = true
    }

    # "preview-v135-a31" = {
    #   node_image    = local.cnode_v1_v135_base_image
    #   image_tag     = local.cnode_v1_v135_image_tag
    #   network       = "preview"
    #   salt          = "a31"
    #   release       = "v135"
    #   magic         = 2
    #   topology_zone = "us-central1-b"
    #   node_version  = "1.35.7"
    #   replicas      = 1
    #   restore       = true
    #   node_resources = {
    #     limits = {
    #       "memory" = "3Gi"
    #       "cpu"    = "8"
    #     }
    #     requests = {
    #       "memory" = "3Gi"
    #       "cpu"    = "100m"
    #     }
    #   }
    # }
  }

  services = {
    # "mainnet-stable" = {
    #   network     = "mainnet"
    #   release     = "stable"
    #   active_salt = "v6g"
    # }
    # "preprod-stable" = {
    #   network     = "preprod"
    #   release     = "stable"
    #   active_salt = "v6g"
    # }
    "preview-stable" = {
      network      = "preview"
      release      = "stable"
      active_salt  = "v6g"
      node_version = local.cnode_v1_default_image_tag
    }
    # "vector-testnet-stable" = {
    #   network     = "vector-testnet"
    #   release     = "stable"
    #   active_salt = "v6g"
    # }
    # "sanchonet-edge" = {
    #   network     = "sanchonet"
    #   release     = "edge"
    #   active_salt = "v6g"
    # }
    # "mainnet-v135" = {
    #   network     = "mainnet"
    #   release     = "v135"
    #   active_salt = "a31"
    # }
    # "preview-v135" = {
    #   network     = "preview"
    #   release     = "v135"
    #   active_salt = "a31"
    # }
    # "preprod-v135" = {
    #   network     = "preprod"
    #   release     = "v135"
    #   active_salt = "a31"
    # }
  }
}
