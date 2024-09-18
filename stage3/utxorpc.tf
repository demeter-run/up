locals {
  // Defaults for UtxoRPC
  utxorpc_defaults = {
    namespace             = "ext-utxorpc-m0"
    dns_zone              = "utxorpc.cloud"
    operator_image_tag    = "40389c34949a6ac5d72d5a887164a6950e1924a0"
    networks              = ["cardano-mainnet", "cardano-preprod", "cardano-preview"]
    cloudflared_image_tag = "latest"
    cloudflared_replicas  = 0
    cloudflared_resources = {
      limits = {
        cpu    = "2"
        memory = "500Mi"
      }
      requests = {
        cpu    = "50m"
        memory = "500Mi"
      }
    }
    cloudflared_tolerations = [
      {
        effect   = "NoSchedule"
        key      = "demeter.run/compute-profile"
        operator = "Exists"
      },
      {
        effect   = "NoSchedule"
        key      = "demeter.run/compute-arch"
        operator = "Exists"
      },
      {
        effect   = "NoSchedule"
        key      = "demeter.run/availability-sla"
        operator = "Exists"
      }
    ]
    proxies_image_tag = "40389c34949a6ac5d72d5a887164a6950e1924a0"
    proxies_replicas  = 0
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
    cloudflared_tunnel_id     = "default-tunnel-id"
    cloudflared_tunnel_secret = "default-tunnel-secret"
    cloudflared_account_tag   = "default-account-tag"
    extension_subdomain       = "utxorpc"
    api_key_salt              = "this is a random generated key and must be shared..."
  }
}

module "ext_cardano_utxorpc" {
  # source   = "git::https://github.com/demeter-run/ext-cardano-utxorpc//bootstrap/"
  source   = "git::https://github.com/blinklabs-io/demeter-ext-cardano-utxorpc.git//bootstrap?ref=feat/use-unnamed-volume"
  for_each = toset([for n in toset(["v1"]) : n if var.enable_cardano_utxorpc])

  operator_image_tag  = local.utxorpc_defaults.operator_image_tag
  extension_subdomain = local.utxorpc_defaults.extension_subdomain
  dns_zone            = local.utxorpc_defaults.dns_zone
  api_key_salt        = local.utxorpc_defaults.api_key_salt
  namespace           = local.utxorpc_defaults.namespace
  networks            = local.utxorpc_defaults.networks

  network_addresses = {
    # "cardano-mainnet" : "relay.utxorpc-m0.demeter.run:3000"
    "cardano-preprod" : "relay.utxorpc-m0.demeter.run:3001"
    # "cardano-preview" : "relay.utxorpc-m0.demeter.run:3002"
  }

  // Cloudflared
  cloudflared_tunnel_id     = local.utxorpc_defaults.cloudflared_tunnel_id
  cloudflared_tunnel_secret = local.utxorpc_defaults.cloudflared_tunnel_secret
  cloudflared_account_tag   = local.utxorpc_defaults.cloudflared_account_tag
  cloudflared_image_tag     = local.utxorpc_defaults.cloudflared_image_tag
  cloudflared_replicas      = local.utxorpc_defaults.cloudflared_replicas
  cloudflared_resources     = local.utxorpc_defaults.cloudflared_resources
  cloudflared_tolerations   = local.utxorpc_defaults.cloudflared_tolerations

  // Proxies
  proxies_image_tag   = local.utxorpc_defaults.proxies_image_tag
  proxies_replicas    = local.utxorpc_defaults.proxies_replicas
  proxies_resources   = local.utxorpc_defaults.proxies_resources
  proxies_tolerations = local.utxorpc_defaults.proxies_tolerations

  cells = {
    "cell1" = {
      # tolerations = [
      #   {
      #     effect   = "NoSchedule"
      #     key      = "demeter.run/compute-arch"
      #     operator = "Equal"
      #     value    = "arm64"
      #   }
      # ]
      pvc = {
        storage_class = "gp-immediate"
        storage_size  = "30Gi"
      }
      instances = {
        "cardano-preprod" = {
          dolos_version = "sha-1618ebb"
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
      }
    }
  }
}
