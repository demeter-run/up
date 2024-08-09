locals {
  utxorpc_namespace           = "ext-utxorpc-m0"
  utxorpc_operator_image_tag  = "62e61904e35c3e92f38e5a41ffbbcc762d7d1331"
  utxorpc_proxy_image_tag     = "0d21946bd688fefaac10c83075ebbee9c2682213"
  utxorpc_dns_zone            = "utxorpc.cloud"
  utxorpc_extension_subdomain = "txpipe-eu"
}

module "utxorpc" {
  # TODO: Not public yet.
  # source = "git::https://github.com/demeter-run/ext-cardano-utxorpc//bootstrap/"
  source = "../../ext-cardano-utxorpc/bootstrap/"

  operator_image_tag        = local.utxorpc_operator_image_tag
  extension_subdomain       = local.utxorpc_extension_subdomain
  dns_zone                  = local.utxorpc_dns_zone
  api_key_salt              = var.utxorpc_api_key_salt
  proxy_image_tag           = local.utxorpc_proxy_image_tag
  namespace                 = local.utxorpc_namespace
  networks                  = ["preprod"]
  cloudflared_tunnel_id     = var.utxorpc_cloudflared_tunnel_id
  cloudflared_tunnel_secret = var.utxorpc_cloudflared_tunnel_secret
  cloudflared_account_tag   = var.utxorpc_cloudflared_account_tag

  network_addresses = {
    "preprod" : "relay.cnode-m1.demeter.run:3001"
  }

  instances = {
    "a2a" : {
      network = "preprod"
      resources = {
        requests = {
          cpu    = "50m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "8G"
        }
        storage = {
          size  = "30Gi"
          class = "gp"
      } }
    }
  }
}
