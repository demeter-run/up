provider "cloudflare" {}

variable "cloudflare_account_id" {}
variable "cloudflare_zone_id" {}
variable "cloudflare_zone_name" {}
variable "cloudflare_tunnels" {
  type = list(object({
    name   = string
    secret = string
  }))
  #sensitive = true
}

locals {
  cloudflare_zone_names = [
    var.cloudflare_zone_name,
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

resource "cloudflare_tunnel" "this" {
  for_each = { for k in var.cloudflare_tunnels : k.name => k }

  account_id = var.cloudflare_account_id
  name       = each.value.name
  secret     = each.value.secret
  config_src = "cloudflare"
}

resource "cloudflare_tunnel_config" "this" {
  for_each = { for k in var.cloudflare_tunnels : k.name => k }

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
  for_each = { for k in var.cloudflare_tunnels : k.name => k }

  depends_on = [cloudflare_zone.this]

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  value   = cloudflare_tunnel.this[each.value.name].cname
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_load_balancer_pool" "tunnels" {
  name = "ProviderTunnels"

  account_id = var.cloudflare_account_id
  monitor    = cloudflare_load_balancer_monitor.tunnels_monitor.id

  dynamic "origins" {
    for_each = { for k in var.cloudflare_tunnels : k.name => k }
    content {
      name    = origins.value.name
      address = cloudflare_tunnel.this[origins.value.name].cname
    }
  }
}

resource "cloudflare_load_balancer" "tunnels" {
  zone_id          = var.cloudflare_zone_id
  name             = "*.${var.cloudflare_zone_name}"
  default_pool_ids = [cloudflare_load_balancer_pool.tunnels.id]
  fallback_pool_id = cloudflare_load_balancer_pool.tunnels.id
  proxied          = true
}

resource "cloudflare_load_balancer_monitor" "tunnels_monitor" {
  account_id     = var.cloudflare_account_id
  type           = "https"
  description    = "Health check for tunnels"
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
