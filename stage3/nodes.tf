locals {
  cnode_v1_namespace          = "ext-nodes-m1"
  cnode_v1_default_base_image = "ghcr.io/blinklabs-io/cardano-node"
  cnode_v1_default_image_tag  = "10.1.3-2"
  cnode_v1_edge_base_image    = "ghcr.io/demeter-run/cardano-node-edge"
  cnode_v1_edge_image_tag     = "be248be99fa238ebb9c2f72e6042739bf02263d6"
  cnode_v1_api_key_salt       = coalesce(var.cnode_v1_api_key_salt, "this is a random generated key and must be shared...")
}

module "ext_cardano_node_crds" {
  source   = "git::https://github.com/demeter-run/ext-cardano-node.git//bootstrap/crds"
  for_each = toset([for n in toset(["global"]) : n if var.enable_cardano_node])
}

module "ext_cardano_node" {
  source                          = "git::https://github.com/demeter-run/ext-cardano-node.git//bootstrap?ref=d9fceba"
  for_each                        = toset([for n in toset(["m1"]) : n if var.enable_cardano_node])
  namespace                       = local.cnode_v1_namespace
  cloud_provider                  = var.cloud_provider
  dns_zone                        = "dmtr.host"
  extension_name                  = "cnode-${each.key}"
  operator_image_tag              = "9f24ebfe1ca56351fa44ab47e5a3fdb815d0f213"
  proxy_blue_extra_annotations    = var.node_proxy_blue_extra_annotations
  proxy_blue_image_tag            = "9f24ebfe1ca56351fa44ab47e5a3fdb815d0f213"
  proxy_blue_replicas             = 1
  proxy_blue_instances_namespace  = local.cnode_v1_namespace
  proxy_blue_healthcheck_port     = 31789
  proxy_green_extra_annotations   = var.node_proxy_green_extra_annotations
  proxy_green_image_tag           = "9f24ebfe1ca56351fa44ab47e5a3fdb815d0f213"
  proxy_green_replicas            = 1
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

    "mainnet-stable-v6g" = {
      node_image    = local.cnode_v1_default_base_image
      image_tag     = local.cnode_v1_default_image_tag
      network       = "mainnet"
      salt          = "v6g"
      release       = "stable"
      magic         = 764824073
      topology_zone = "us-central1-a"
      node_resources = {
        limits = {
          "memory" = "24Gi"
          "cpu"    = "4"
        }
        requests = {
          "memory" = "4Gi"
          "cpu"    = "2"
        }
      }
      storage_size       = var.storage_size_mainnet
      storage_class_name = var.storage_class_name_mainnet
      node_version       = local.cnode_v1_default_image_tag
      replicas           = 1
      restore            = true
      tolerations = [
        {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = var.toleration_k8s_arch_mainnet
        }
      ]
    }

    "preprod-stable-v6g" = {
      node_image    = local.cnode_v1_default_base_image
      image_tag     = local.cnode_v1_default_image_tag
      network       = "preprod"
      salt          = "v6g"
      release       = "stable"
      magic         = 1
      topology_zone = "us-central1-a"
      node_resources = {
        limits = {
          "memory" = "8Gi"
          "cpu"    = "8"
        }
        requests = {
          "memory" = "8Gi"
          "cpu"    = "100m"
        }
      }
      storage_size       = var.storage_size_preprod
      storage_class_name = var.storage_class_name_preprod
      node_version       = local.cnode_v1_default_image_tag
      replicas           = 1
      restore            = true
      tolerations = [
        {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = var.toleration_k8s_arch_preprod
        }
      ]
    }

    "preview-stable-v6g" = {
      node_image    = local.cnode_v1_default_base_image
      image_tag     = local.cnode_v1_default_image_tag
      network       = "preview"
      salt          = "v6g"
      release       = "stable"
      magic         = 2
      topology_zone = "us-central1-a"
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
      storage_size       = var.storage_size_preview
      storage_class_name = var.storage_class_name_preview
      node_version       = local.cnode_v1_default_image_tag
      replicas           = 1
      restore            = true
      tolerations = [
        {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = var.toleration_k8s_arch_preview
        }
      ]
    }
  }

  services = {
    "mainnet-stable" = {
      network      = "mainnet"
      release      = "stable"
      node_version = local.cnode_v1_default_image_tag
      active_salt  = "v6g"
    }
    "preprod-stable" = {
      network      = "preprod"
      release      = "stable"
      node_version = local.cnode_v1_default_image_tag
      active_salt  = "v6g"
    }
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
  }
}
