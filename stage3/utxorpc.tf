locals {
  // Defaults for UtxoRPC
  utxorpc_defaults = {
    namespace          = "ext-utxorpc-m0"
    dns_zone           = "dmtr.host"
    operator_image_tag = "0ecf1644a0554d3c34f4256b6765c80a02986e15"
    networks           = ["cardano-mainnet", "cardano-preprod", "cardano-preview"]
    extension_url_per_network = {
      "cardano-mainnet" = "utxorpc-m0.demeter.run"
      "cardano-preprod" = "utxorpc-preprod.demeter.run"
      "cardano-preview" = "utxorpc-preview.demeter.run"
    }
    proxies_image_tag = "7941eec9a681ace6fdaeb7e18d9fb2b26d3cfae3"
    proxies_replicas  = 1
    proxies_resources = {
      limits = {
        cpu    = "2"
        memory = "250Mi"
      }
      requests = {
        cpu    = "50m"
        memory = "250Mi"
      }
    }
    proxies_tolerations = [
      {
        effect   = "NoSchedule"
        key      = "demeter.run/compute-profile"
        operator = "Exists"
      },
      {
        effect   = "NoSchedule"
        key      = "demeter.run/compute-arch"
        operator = "Equal"
        value    = "x86"
      },
      {
        effect   = "NoSchedule"
        key      = "demeter.run/availability-sla"
        operator = "Exists"
      }
    ]
    dolos_version       = "sha-e0f42cf"
    extension_subdomain = "utxorpc"
    api_key_salt        = "this is a random generated key and must be shared..."
  }
}

module "ext_cardano_utxorpc_crds" {
  source   = "git::https://github.com/demeter-run/ext-cardano-utxorpc//bootstrap/crds"
  for_each = toset(var.enable_cardano_utxorpc ? ["global"] : [])
}

module "ext_cardano_utxorpc" {
  source   = "git::https://github.com/demeter-run/ext-cardano-utxorpc//bootstrap?ref=91cd15a"
  for_each = toset([for n in toset(["v1"]) : n if var.enable_cardano_utxorpc])

  operator_image_tag        = local.utxorpc_defaults.operator_image_tag
  extension_url_per_network = local.utxorpc_defaults.extension_url_per_network
  api_key_salt              = local.utxorpc_defaults.api_key_salt
  namespace                 = local.utxorpc_defaults.namespace
  networks                  = local.utxorpc_defaults.networks

  network_addresses = {
    # "cardano-mainnet" : "relay.utxorpc-m0.demeter.run:3000"
    # "cardano-preprod" : "relay.utxorpc-m0.demeter.run:3001"
    # "cardano-preview" : "relay.utxorpc-m0.demeter.run:3002"
  }

  // Proxies
  proxies_image_tag   = local.utxorpc_defaults.proxies_image_tag
  proxies_replicas    = local.utxorpc_defaults.proxies_replicas
  proxies_resources   = local.utxorpc_defaults.proxies_resources
  proxies_tolerations = local.utxorpc_defaults.proxies_tolerations

  cells = {
    "cell1" = {
      tolerations = [
        {
          effect   = "NoSchedule"
          key      = "demeter.run/availability-sla"
          operator = "Equal"
          value    = "consistent"
        },
        {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-arch"
          operator = "Equal"
          value    = "arm64"
        },
        {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Equal"
          value    = "disk-intensive"
        },
        {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "arm64"
        }
      ]
      pvc = {
        storage_class = "gp"
        storage_size  = "600Gi"
      }
      instances = {
        "cardano-preview" = {
          dolos_version = local.utxorpc_defaults.dolos_version
          replicas      = 1
          resources = {
            limits = {
              cpu    = "1000m"
              memory = "8Gi"
            }
            requests = {
              cpu    = "50m"
              memory = "512Mi"
            }
          }
        }
        "cardano-preprod" = {
          dolos_version = local.utxorpc_defaults.dolos_version
          replicas      = 1
          resources = {
            limits = {
              cpu    = "1000m"
              memory = "8Gi"
            }
            requests = {
              cpu    = "50m"
              memory = "512Mi"
            }
          }
        }
        "cardano-mainnet" = {
          dolos_version = local.utxorpc_defaults.dolos_version
          replicas      = 1
          resources = {
            limits = {
              cpu    = "2"
              memory = "8Gi"
            }
            requests = {
              cpu    = "50m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}
