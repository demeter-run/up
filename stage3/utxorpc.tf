/* UtxoRPC extension

For full information for all the options to set up this extension, visit 
https://github.com/demeter-run/ext-cardano-utxorpc/.

The variable utxorpc is used to configure this module. If undefined the extension isnt
added to the cluster. A minimal valid value for the utxorpc variable is the following:

{
  // Must be provided by Demeter
  extension_subdomain : "txpipe-us-east-1"
  api_key_salt : "random string"
  cloudflared_tunnel_id : "364496d3-8979-4bce-9626-952722c0ddc3"
  cloudflared_tunnel_secret : "Smz1nrp1Iki1YCpGljvJ1HOWjt39Hx6wZA902vvty/A="
  cloudflared_account_tag : "ac5ad90cf6f83abc85ee304a2bb2de73"

  // Defined by user. Each cell is comprised of a PVC, a CloudFlared deployment,
  // a Proxy deployment and an instance per network.
  cells : {
    "a2b" : {
      pvc : {
        storage_class = "nvme"
        storage_size  = "434Gi"
        volume_name   = "local-pv-uawnddc"
      }
      instances : {
        "mainnet" : {
          dolos_version : "v0.14.1"
          resources = {
            requests = {
              cpu    = "500m"
              memory = "5G"
            }
            limits = {
              cpu    = "8"
              memory = "5G"
            }
          }
        }
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
        "preview" : {
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
  utxorpc_operator_image_tag = "ae44a17c25333c628ca68625ce0006a5ac0b8e09"
  utxorpc_proxy_image_tag    = "e27daad361a5f72993e0fa8d4060db03e5da54f8"
  utxorpc_networks           = ["mainnet", "preprod", "preview"]
}

module "utxorpc" {
  # TODO: Not public yet.
  # source = "git::https://github.com/demeter-run/ext-cardano-utxorpc//bootstrap/"
  source = "../../ext-cardano-utxorpc/bootstrap/"
  count  = var.utxorpc != null ? 1 : 0

  operator_image_tag        = coalesce(var.utxorpc.operator_image_tag, local.utxorpc_operator_image_tag)
  proxy_image_tag           = coalesce(var.utxorpc.proxy_image_tag, local.utxorpc_proxy_image_tag)
  extension_subdomain       = var.utxorpc.extension_subdomain
  dns_zone                  = coalesce(var.utxorpc.dns_zone, local.utxorpc_dns_zone)
  api_key_salt              = var.utxorpc.api_key_salt
  namespace                 = coalesce(var.utxorpc.namespace, local.utxorpc_namespace)
  networks                  = coalesce(var.utxorpc.networks, local.utxorpc_networks)
  cloudflared_tunnel_id     = var.utxorpc.cloudflared_tunnel_id
  cloudflared_tunnel_secret = var.utxorpc.cloudflared_tunnel_secret
  cloudflared_account_tag   = var.utxorpc.cloudflared_account_tag

  network_addresses = {
    "mainnet" : "relay.cnode-m1.demeter.run:3000"
    "preprod" : "relay.cnode-m1.demeter.run:3001"
    "preview" : "relay.cnode-m1.demeter.run:3002"
  }

  cells = var.utxorpc.cells
}
