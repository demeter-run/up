provider "cloudflare" {}

variable "cloudflare_account_id" {}
variable "cloudflare_zone_id" {}
variable "cloudflare_zone_name" {}
variable "cloudflare_tunnel_secrets" {
  sensitive = true
}

locals {
  cloudflare_zone_names = [
    var.cloudflare_zone_name,
  ]
}

locals {
  demeter_providers = [
    {
      name   = "blinklabs-us"
      cardano_node = {
        enabled = true
        address = "blinklabs-us-cardano-node.blinklabs.io"
      }
      kupo = {
        enabled = true
        address = "blinklabs-us-kupo.blinklabs.io"
      }
      ogmios = {
        enabled = true
        address = "blinklabs-us-ogmios.blinklabs.io"
      }
      tunnel = {
        enabled = true
      }
    },
    {
      name   = "txpipe-eu"
      cardano_node = {
        enabled = true
        address = "eu-cardano-node.txpipe.cloud"
      }
      kupo = {
        enabled = true
        address = "eu-kupo.txpipe.cloud"
      }
      ogmios = {
        enabled = true
        address = "eu-ogmios.txpipe.cloud"
      }
      tunnel = {
        enabled = true
      }
    },
  ]
}


# We use for_each on this to expose the domain names in the resource names
resource "cloudflare_zone" "this" {
  for_each   = toset(local.cloudflare_zone_names)
  account_id = var.cloudflare_account_id
  zone       = each.key
  plan       = "free"
  jump_start = false
}

# Zone settings
# The commented items don't seem to be supported on free plans
resource "cloudflare_zone_settings_override" "this" {
  for_each = toset(local.cloudflare_zone_names)

  zone_id = cloudflare_zone.this[each.key].id

  settings {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    brotli                   = "on"
    browser_cache_ttl        = 300
    cache_level              = "basic"
    early_hints              = "on"
    h2_prioritization        = "on"
    http2                    = "on"
    http3                    = "on"
    min_tls_version          = "1.2"
    #mirage                   = "on"
    opportunistic_encryption = "on"
    #polish                   = "lossless"
    rocket_loader            = "on"
    ssl                      = "strict"
    tls_1_3                  = "on"
    webp                     = "on"
    websockets               = "on"
    security_header {
      enabled            = true
      preload            = true
      max_age            = 31536000
      include_subdomains = true
    }
  }
}

# Tunnels

resource "cloudflare_tunnel" "this" {
  for_each = { for p in local.demeter_providers: p.name => p if p.tunnel.enabled }

  account_id = var.cloudflare_account_id
  name       = each.value.name
  secret     = var.cloudflare_tunnel_secrets[each.value.name]
  config_src = "cloudflare"
}

resource "cloudflare_tunnel_config" "this" {
  for_each = { for p in local.demeter_providers: p.name => p if p.tunnel.enabled }

  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.this[each.value.name].id

  config {
    ingress_rule {
      service  = "http://kong-kong-proxy:80"
      hostname = "*.${var.cloudflare_zone_name}"
    }

    ingress_rule {
      service  = "http://kong-kong-proxy:80"
      hostname = "${each.value.name}.${var.cloudflare_zone_name}"
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "tunnels" {
  for_each = { for p in local.demeter_providers: p.name => p if p.tunnel.enabled }

  depends_on = [cloudflare_zone.this]

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  value   = cloudflare_tunnel.this[each.value.name].cname
  type    = "CNAME"
  proxied = true
}

# Cardano Node

resource "cloudflare_load_balancer_pool" "cardano_node_m1" {
  name = "CardanoNodeM1"

  account_id = var.cloudflare_account_id
  monitor    = cloudflare_load_balancer_monitor.cardano_node_m1_monitor.id

  dynamic "origins" {
    for_each = { for p in local.demeter_providers : p.name => p if p.cardano_node.enabled }
    content {
      name    = origins.value.name
      address = origins.value.cardano_node.address != "" ? origins.value.cardano_node.address : "${origins.value.name}.${var.cloudflare_zone_name}"
    }
  }
}

resource "cloudflare_load_balancer" "cardano_node_m1" {
  zone_id          = var.cloudflare_zone_id
  name             = "*.cnode-m1.${var.cloudflare_zone_name}"
  default_pool_ids = [cloudflare_load_balancer_pool.cardano_node_m1.id]
  fallback_pool_id = cloudflare_load_balancer_pool.cardano_node_m1.id
  proxied          = false
}

resource "cloudflare_load_balancer_monitor" "cardano_node_m1_monitor" {
  account_id     = var.cloudflare_account_id
  type           = "http"
  description    = "Health check for cardano_node_m1"
  path           = "/healthcheck"
  interval       = 60
  timeout        = 5
  retries        = 2
  method         = "GET"
  expected_codes = "200"

  header {
    header = "Host"
    values = ["cnode-m1.dmtr.host"]
  }
}

# Kupo

resource "cloudflare_load_balancer_pool" "kupo_m1" {
  name = "KupoM1"

  account_id = var.cloudflare_account_id
  monitor    = cloudflare_load_balancer_monitor.kupo_m1_monitor.id

  dynamic "origins" {
    for_each = { for p in local.demeter_providers : p.name => p if p.kupo.enabled }
    content {
      name    = origins.value.name
      address = origins.value.kupo.address != "" ? origins.value.kupo.address : "${origins.value.name}.${var.cloudflare_zone_name}"
    }
  }
}

resource "cloudflare_load_balancer" "kupo_m1" {
  zone_id          = var.cloudflare_zone_id
  name             = "*.kupo-m1.${var.cloudflare_zone_name}"
  default_pool_ids = [cloudflare_load_balancer_pool.kupo_m1.id]
  fallback_pool_id = cloudflare_load_balancer_pool.kupo_m1.id
  proxied          = false
}

resource "cloudflare_load_balancer_monitor" "kupo_m1_monitor" {
  account_id     = var.cloudflare_account_id
  type           = "http"
  description    = "Health check for kupo_m1"
  path           = "/healthcheck"
  interval       = 60
  timeout        = 5
  retries        = 2
  method         = "GET"
  expected_codes = "200"

  header {
    header = "Host"
    values = ["health.kupo-m1.dmtr.host"]
  }
}

# Ogmios

resource "cloudflare_load_balancer_pool" "ogmios_m1" {
  name = "OgmiosM1"

  account_id = var.cloudflare_account_id
  monitor    = cloudflare_load_balancer_monitor.ogmios_m1_monitor.id

  dynamic "origins" {
    for_each = { for p in local.demeter_providers : p.name => p if p.ogmios.enabled }
    content {
      name    = origins.value.name
      address = origins.value.ogmios.address != "" ? origins.value.ogmios.address : "${origins.value.name}.${var.cloudflare_zone_name}"
    }
  }
}

resource "cloudflare_load_balancer" "ogmios_m1" {
  zone_id          = var.cloudflare_zone_id
  name             = "*.ogmios-m1.${var.cloudflare_zone_name}"
  default_pool_ids = [cloudflare_load_balancer_pool.ogmios_m1.id]
  fallback_pool_id = cloudflare_load_balancer_pool.ogmios_m1.id
  proxied          = false
}

resource "cloudflare_load_balancer_monitor" "ogmios_m1_monitor" {
  account_id     = var.cloudflare_account_id
  type           = "https"
  description    = "Health check for ogmios_m1"
  path           = "/healthz"
  interval       = 60
  timeout        = 5
  retries        = 2
  method         = "GET"
  expected_codes = "200"

  header {
    header = "Host"
    values = ["health.ogmios-m1.dmtr.host"]
  }
}

# Workloads

resource "cloudflare_load_balancer_pool" "workloads" {
  name = "Workloads"

  account_id = var.cloudflare_account_id
  monitor    = cloudflare_load_balancer_monitor.workloads_monitor.id

  dynamic "origins" {
    for_each = { for p in local.demeter_providers : p.name => p if p.tunnel.enabled }
    content {
      name    = origins.value.name
      address = cloudflare_tunnel.this[origins.value.name].cname
    }
  }
}

resource "cloudflare_load_balancer" "workloads" {
  zone_id          = var.cloudflare_zone_id
  name             = "*.${var.cloudflare_zone_name}"
  default_pool_ids = [cloudflare_load_balancer_pool.workloads.id]
  fallback_pool_id = cloudflare_load_balancer_pool.workloads.id
  proxied          = true
}

resource "cloudflare_load_balancer_monitor" "workloads_monitor" {
  account_id     = var.cloudflare_account_id
  type           = "https"
  description    = "Health check for workloads"
  path           = "/ping_provider_healthcheck"
  interval       = 60
  timeout        = 5
  retries        = 2
  method         = "GET"
  expected_codes = "200"

  header {
    header = "Host"
    values = ["health.dmtr.host"]
  }
}
