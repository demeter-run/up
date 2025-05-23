locals {
  ogmios_v1_namespace             = "ext-ogmios-m1"
  ogmios_v1_networks              = ["preview", "preprod", "mainnet"]
  ogmios_v1_operator_image_tag    = "0a07337a698e4fd77f59557d66d547e95445064f"
  ogmios_v1_metrics_delay         = 60
  ogmios_v1_api_key_salt          = coalesce(var.ogmios_v1_api_key_salt, "this is a random generated key and must be shared...")
  ogmios_v1_dns_zone              = var.ogmios_dns_zone
  ogmios_v1_cluster_issuer        = "letsencrypt-dns01"
  ogmios_v1_proxy_green_image_tag = "0a07337a698e4fd77f59557d66d547e95445064f"
  ogmios_v1_proxy_green_replicas  = "1"
  ogmios_v1_proxy_blue_image_tag  = "0a07337a698e4fd77f59557d66d547e95445064f"
  ogmios_v1_proxy_blue_replicas   = "1"
  ogmios_v1_proxy_resources = {
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

module "ext_cardano_ogmios_crds" {
  source   = "git::https://github.com/demeter-run/ext-cardano-ogmios.git//bootstrap/crds"
  for_each = toset(var.enable_cardano_ogmios ? ["global"] : [])
}

module "ext_cardano_ogmios" {
  source                                   = "git::https://github.com/demeter-run/ext-cardano-ogmios.git//bootstrap?ref=fcae7c5"
  for_each                                 = toset([for n in toset(["v1"]) : n if var.enable_cardano_ogmios])
  namespace                                = local.ogmios_v1_namespace
  networks                                 = local.ogmios_v1_networks
  operator_image_tag                       = local.ogmios_v1_operator_image_tag
  metrics_delay                            = local.ogmios_v1_metrics_delay
  api_key_salt                             = local.ogmios_v1_api_key_salt
  dns_zone                                 = local.ogmios_v1_dns_zone
  cluster_issuer                           = local.ogmios_v1_cluster_issuer
  proxy_green_extra_annotations_by_network = var.ogmios_proxy_green_extra_annotations_by_network
  proxy_green_image_tag                    = local.ogmios_v1_proxy_green_image_tag
  proxy_green_replicas                     = local.ogmios_v1_proxy_green_replicas
  proxy_blue_extra_annotations_by_network  = var.ogmios_proxy_blue_extra_annotations_by_network
  proxy_blue_image_tag                     = local.ogmios_v1_proxy_blue_image_tag
  proxy_blue_replicas                      = local.ogmios_v1_proxy_blue_replicas
  proxy_resources                          = local.ogmios_v1_proxy_resources
  cloud_provider                           = var.cloud_provider

  instances = {
    "instance1" = {
      salt    = "samplesalt"
      network = "preview"
      # Image_tag for version 6
      ogmios_image     = "ghcr.io/demeter-run/ext-cardano-ogmios-instance-6:c9ed9cdc4fa5db2140ea4ec44fa8bb984f3fc2e8"
      node_private_dns = "node-preview-stable.ext-nodes-m1.svc.cluster.local:3307"
      ogmios_version   = "6"
      replicas         = 1
      compute_arch     = "arm64"
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
      tolerations = [
        {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Exists"
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
              match_expressions = var.ogmos_topology_az1
            }
          ]
        }
      }
    }
    "instance2" = {
      salt    = "samplesalt"
      network = "preprod"
      # Image_tag for version 6
      ogmios_image     = "ghcr.io/demeter-run/ext-cardano-ogmios-instance-6:c9ed9cdc4fa5db2140ea4ec44fa8bb984f3fc2e8"
      node_private_dns = "node-preprod-stable.ext-nodes-m1.svc.cluster.local:3307"
      ogmios_version   = "6"
      replicas         = 1
      compute_arch     = "arm64"
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
      tolerations = [
        {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Exists"
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
              match_expressions = var.ogmos_topology_az1
            }
          ]
        }
      }
    }
    "instance3" = {
      salt    = "samplesalt"
      network = "mainnet"
      # Image_tag for version 6
      ogmios_image     = "ghcr.io/demeter-run/ext-cardano-ogmios-instance-6:c9ed9cdc4fa5db2140ea4ec44fa8bb984f3fc2e8"
      node_private_dns = "node-mainnet-stable.ext-nodes-m1.svc.cluster.local:3307"
      ogmios_version   = "6"
      replicas         = 1
      compute_arch     = "arm64"
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
      tolerations = [
        {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Exists"
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
              match_expressions = var.ogmos_topology_az1
            }
          ]
        }
      }
    }
  }
}
