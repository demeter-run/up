/* UtxoRPC extension

For full information for all the options to set up this extension, visit
https://github.com/demeter-run/ext-cardano-utxorpc/.

The variable utxorpc is used to configure this module. If undefined the
extension isnt added to the cluster. A minimal valid value for the utxorpc
variable is the following:

{
  // Must be provided by Demeter
  extension_subdomain : "txpipe-us-east-1"
  api_key_salt : "random string"
  cloudflared_tunnel_id : "tunnel-id"
  cloudflared_tunnel_secret : "tunnel-secret"
  cloudflared_account_tag : "account-tag"
  networks : ["cardano-preprod"]

  // Defined by user. Each cell is comprised of a PVC and the Dolos instances
  // (one per network)
  cells : {
    "a2b" : {
      pvc : {
        storage_class = "fast"
        storage_size  = "50Gi"
        volume_name   = "pv-utxorpc-a2b"
      }
      instances : {
        "preprod" : {
          dolos_version : "v0.14.1"
          resources = {
            requests = {
              cpu    = "500m"
              memory = "5G"
            }
            limits = {
              cpu    = "1000m"
              memory = "5G"
            }
          }
        }
      }
    }
  }
}
*/

locals {
  // Defaults
  utxorpc_namespace          = "ext-utxorpc-m0"
  utxorpc_dns_zone           = "utxorpc.cloud"
  utxorpc_operator_image_tag = "40389c34949a6ac5d72d5a887164a6950e1924a0"
  utxorpc_networks           = ["cardano-mainnet", "cardano-preprod", "cardano-preview"]

  utxorpc_cloudflared_image_tag = "latest"
  utxorpc_cloudflared_replicas  = 2
  utxorpc_cloudflared_resources = {
    limits : {
      cpu : "2",
      memory : "500Mi"
    }
    requests : {
      cpu : "50m",
      memory : "500Mi"
    }
  }
  utxorpc_cloudflared_tolerations = [
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

  utxorpc_proxies_image_tag = "40389c34949a6ac5d72d5a887164a6950e1924a0"
  utxorpc_proxies_replicas  = 2
  utxorpc_proxies_resources = {
    limits : {
      cpu : "2",
      memory : "250Mi"
    }
    requests : {
      cpu : "50m",
      memory : "250Mi"
    }
  }
  utxorpc_proxies_tolerations = [
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
}

module "utxorpc" {
  # TODO: Not public yet.
  # source = "git::https://github.com/demeter-run/ext-cardano-utxorpc//bootstrap/"
  source = "../../ext-cardano-utxorpc/bootstrap/"
  count  = var.utxorpc != null ? 1 : 0

  operator_image_tag  = coalesce(var.utxorpc.operator_image_tag, local.utxorpc_operator_image_tag)
  extension_subdomain = var.utxorpc.extension_subdomain
  dns_zone            = coalesce(var.utxorpc.dns_zone, local.utxorpc_dns_zone)
  api_key_salt        = var.utxorpc.api_key_salt
  namespace           = coalesce(var.utxorpc.namespace, local.utxorpc_namespace)
  networks            = coalesce(var.utxorpc.networks, local.utxorpc_networks)

  network_addresses = {
    "cardano-mainnet" : "relay.cnode-m1.demeter.run:3000"
    "cardano-preprod" : "relay.cnode-m1.demeter.run:3001"
    "cardano-preview" : "relay.cnode-m1.demeter.run:3002"
  }

  // Cloudflared
  cloudflared_tunnel_id     = var.utxorpc.cloudflared_tunnel_id
  cloudflared_tunnel_secret = var.utxorpc.cloudflared_tunnel_secret
  cloudflared_account_tag   = var.utxorpc.cloudflared_account_tag
  cloudflared_image_tag     = coalesce(var.utxorpc.cloudflared_image_tag, local.utxorpc_cloudflared_image_tag)
  cloudflared_replicas      = coalesce(var.utxorpc.cloudflared_replicas, local.utxorpc_cloudflared_replicas)
  cloudflared_resources     = coalesce(var.utxorpc.cloudflared_resources, local.utxorpc_cloudflared_resources)
  cloudflared_tolerations   = coalesce(var.utxorpc.cloudflared_tolerations, local.utxorpc_cloudflared_tolerations)

  // Proxies
  proxies_image_tag   = coalesce(var.utxorpc.proxies_image_tag, local.utxorpc_proxies_image_tag)
  proxies_replicas    = coalesce(var.utxorpc.proxies_replicas, local.utxorpc_proxies_replicas)
  proxies_resources   = coalesce(var.utxorpc.proxies_resources, local.utxorpc_proxies_resources)
  proxies_tolerations = coalesce(var.utxorpc.proxies_tolerations, local.utxorpc_proxies_tolerations)

  cells = var.utxorpc.cells
}
