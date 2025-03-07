locals {
  kupo_v1_namespace = "ext-kupo-m1"
  // Specify networks for services and configurations
  kupo_v1_cluster_issuer     = "letsencrypt-dns01"
  kupo_v1_networks           = ["preview", "preprod", "mainnet"]
  kupo_v1_operator_image_tag = "aab07d8cd8fe0fa80281550ce3845108a37f5a0b"
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
  kupo_v1_extension_subdomain   = "kupo-m1"
  kupo_v1_dns_zone              = "dmtr.host"
  kupo_v1_proxy_green_image_tag = "9c0d2ed7d7758c85106d65a171f306bba7d5c64a"
  kupo_v1_proxy_green_replicas  = "1"
  kupo_v1_proxy_blue_image_tag  = "9c0d2ed7d7758c85106d65a171f306bba7d5c64a"
  kupo_v1_proxy_blue_replicas   = "1"
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
  source             = "git::https://github.com/demeter-run/ext-cardano-kupo.git//bootstrap?ref=c196b08"
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
  api_key_salt                  = local.kupo_v1_api_key_salt
  ingress_class                 = local.kupo_v1_ingress_class
  extension_subdomain           = local.kupo_v1_extension_subdomain
  dns_zone                      = local.kupo_v1_dns_zone
  proxy_green_extra_annotations = var.kupo_proxy_green_extra_annotations
  proxy_green_image_tag         = local.kupo_v1_proxy_green_image_tag
  proxy_green_replicas          = local.kupo_v1_proxy_green_replicas
  proxy_blue_extra_annotations  = var.kupo_proxy_blue_extra_annotations
  proxy_blue_image_tag          = local.kupo_v1_proxy_blue_image_tag
  proxy_blue_replicas           = local.kupo_v1_proxy_blue_replicas
  proxy_resources               = local.kupo_v1_proxy_resources
  cells = {
    "cell1" = {
      pvc = {
        storage_size       = var.kupo_v1_storage_size_preview
        storage_class_name = var.kupo_v1_storage_class_name
        access_mode        = "ReadWriteOnce"
      }
      instances = {
        "instance1" = {
          image_tag     = "b035b32b4f190eb74b7e5a8a83aee6f7afa43495"
          network       = "preview"
          pruned        = true
          defer_indexes = true
          # Node connection to socket over n2c
          n2n_endpoint = "node-preview-stable.ext-nodes-m1.svc.cluster.local:3307"
          resources = {
            limits = {
              cpu    = "1"
              memory = "4Gi"
            }
            requests = {
              cpu    = "250m"
              memory = "4Gi"
            }
          }
          tolerations = [
            {
              effect   = "NoSchedule"
              key      = "demeter.run/compute-profile"
              operator = "Equal"
              value    = "disk-intensive"
            },
            {
              effect   = "NoSchedule"
              key      = "demeter.run/compute-arch"
              operator = "Equal"
              value    = "arm64"
            },
            {
              effect   = "NoSchedule"
              key      = "demeter.run/availability-sla"
              operator = "Equal"
              value    = "consistent"
            },
            {
              effect   = "NoSchedule"
              key      = "kubernetes.io/arch"
              operator = "Equal"
              value    = "arm64"
            }
          ]
          node_affinity = {
            required_during_scheduling_ignored_during_execution = {
              node_selector_term = [
                {
                  match_expressions = var.kupo_v1_cell1_preview_node_affinity
                }
              ]
            }
          }
        }
      }
    }
    "cell2" = {
      pvc = {
        storage_size       = var.kupo_v1_storage_size_preprod
        storage_class_name = var.kupo_v1_storage_class_name
        access_mode        = "ReadWriteOnce"
      }
      instances = {
        "instance1" = {
          image_tag     = "b035b32b4f190eb74b7e5a8a83aee6f7afa43495"
          network       = "preprod"
          pruned        = true
          defer_indexes = true
          # Node connection to socket over n2c
          n2n_endpoint = "node-preprod-stable.ext-nodes-m1.svc.cluster.local:3307"
          resources = {
            limits = {
              cpu    = "1"
              memory = "4Gi"
            }
            requests = {
              cpu    = "250m"
              memory = "4Gi"
            }
          }
          tolerations = [
            {
              effect   = "NoSchedule"
              key      = "demeter.run/compute-profile"
              operator = "Equal"
              value    = "disk-intensive"
            },
            {
              effect   = "NoSchedule"
              key      = "demeter.run/compute-arch"
              operator = "Equal"
              value    = "arm64"
            },
            {
              effect   = "NoSchedule"
              key      = "demeter.run/availability-sla"
              operator = "Equal"
              value    = "consistent"
            },
            {
              effect   = "NoSchedule"
              key      = "kubernetes.io/arch"
              operator = "Equal"
              value    = "arm64"
            }
          ]
          node_affinity = {
            required_during_scheduling_ignored_during_execution = {
              node_selector_term = [
                {
                  match_expressions = var.kupo_v1_cell2_preprod_node_affinity
                }
              ]
            }
          }
        }
      }
    }
    "cell3" = {
      pvc = {
        storage_size       = var.kupo_v1_storage_size_mainnet
        storage_class_name = var.kupo_v1_storage_class_name
        access_mode        = "ReadWriteOnce"
      }
      instances = {
        "instance1" = {
          image_tag     = "b035b32b4f190eb74b7e5a8a83aee6f7afa43495"
          network       = "mainnet"
          pruned        = true
          defer_indexes = true
          # Node connection to socket over n2c
          n2n_endpoint = "node-mainnet-stable.ext-nodes-m1.svc.cluster.local:3307"
          resources = {
            limits = {
              cpu    = "1"
              memory = "4Gi"
            }
            requests = {
              cpu    = "250m"
              memory = "4Gi"
            }
          }
          tolerations = [
            {
              effect   = "NoSchedule"
              key      = "demeter.run/compute-profile"
              operator = "Equal"
              value    = "disk-intensive"
            },
            {
              effect   = "NoSchedule"
              key      = "demeter.run/compute-arch"
              operator = "Equal"
              value    = "arm64"
            },
            {
              effect   = "NoSchedule"
              key      = "demeter.run/availability-sla"
              operator = "Equal"
              value    = "consistent"
            },
            {
              effect   = "NoSchedule"
              key      = "kubernetes.io/arch"
              operator = "Equal"
              value    = "arm64"
            }
          ]
          node_affinity = {
            required_during_scheduling_ignored_during_execution = {
              node_selector_term = [
                {
                  match_expressions = var.kupo_v1_cell3_mainnet_node_affinity
                }
              ]
            }
          }
        }
      }
    }
  }
}
