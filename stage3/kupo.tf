locals {
  kupo_v1_namespace = "ext-kupo-m1"
  // Specify networks for services and configurations
  # kupo_v1_networks           = ["mainnet", "preprod", "preview"]
  kupo_v1_cluster_issuer     = "letsencrypt-dns01"
  kupo_v1_networks           = ["preview"]
  kupo_v1_operator_image_tag = "7ed38ec1bd825490a7e7b9b8c130415084ea8976"
  kupo_v1_metrics_delay      = 60
  kupo_v1_per_min_dcus = {
    mainnet = "36"
    default = "16"
  }
  kupo_v1_per_request_dcus = {
    mainnet = "10"
    default = "5"
  }
  kupo_v1_track_dcu_usage       = "true"
  kupo_v1_api_key_salt          = coalesce(var.kupo_v1_api_key_salt, "this is a random generated key and must be shared...")
  kupo_v1_ingress_class         = "kong"
  kupo_v1_extension_subdomain   = "kupo"
  kupo_v1_dns_zone              = "dmtr.host"
  kupo_v1_proxy_green_image_tag = "e7e26f0e3e82ceabf04ceee6d536d500e14e02ab"
  kupo_v1_proxy_green_replicas  = "1"
  kupo_v1_proxy_blue_image_tag  = "e7e26f0e3e82ceabf04ceee6d536d500e14e02ab"
  kupo_v1_proxy_blue_replicas   = "0"
  kupo_v1_proxy_resources = {
    limits = {
      cpu    = "100m"
      memory = "500Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "500Mi"
    }
  }
}

module "ext_cardano_kupo_crds" {
  source   = "git::https://github.com/demeter-run/ext-cardano-kupo.git//bootstrap/crds"
  for_each = toset(var.enable_cardano_kupo ? ["global"] : [])
}

module "ext_cardano_kupo" {
  # source             = "git::https://github.com/demeter-run/ext-cardano-kupo.git//bootstrap?ref=feat/ext-kupo-demeter-up"
  source             = "git::https://github.com/verbotenj/ext-cardano-kupo.git//bootstrap?ref=feat/ext-kupo-demeter-up"
  for_each           = toset([for n in toset(["v1"]) : n if var.enable_cardano_kupo])
  namespace          = "ftr-kupo-${each.key}"
  cloud_provider     = var.cloud_provider
  cluster_issuer     = local.kupo_v1_cluster_issuer
  networks           = local.kupo_v1_networks
  operator_image_tag = local.kupo_v1_operator_image_tag
  metrics_delay      = local.kupo_v1_metrics_delay
  # Specify DCU usage for services to overwrites the default values
  # per_min_dcus          = local.kupo_v1_per_min_dcus
  # per_request_dcus      = local.kupo_v1_per_request_dcus
  # track_dcu_usage       = local.kupo_v1_track_dcu_usage
  api_key_salt          = local.kupo_v1_api_key_salt
  ingress_class         = local.kupo_v1_ingress_class
  extension_subdomain   = local.kupo_v1_extension_subdomain
  dns_zone              = local.kupo_v1_dns_zone
  proxy_green_image_tag = local.kupo_v1_proxy_green_image_tag
  proxy_green_replicas  = local.kupo_v1_proxy_green_replicas
  proxy_blue_image_tag  = local.kupo_v1_proxy_blue_image_tag
  proxy_blue_replicas   = local.kupo_v1_proxy_blue_replicas
  proxy_resources       = local.kupo_v1_proxy_resources
  cells = {
    "cell1" = {
      pvc = {
        storage_size       = "10Gi"
        storage_class_name = "gp-immediate"
        access_mode        = "ReadWriteOnce"
      }
      instances = {
        "instance1" = {
          image_tag = "b035b32b4f190eb74b7e5a8a83aee6f7afa43495"
          network   = "preview"
          pruned    = true
          # Node connection to socket over n2c
          n2n_endpoint = "node-preview-stable.ext-nodes-m1.svc.cluster.local:3307"
          resources = {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

