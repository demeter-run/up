variable "k8s_config" {
  description = "the location of the k8s configuration"
  default     = "~/.kube/config"
}

variable "k8s_context" {
  description = "the name of the k8s context as defined in the kube config file"
}

variable "dmtr_namespace" {
  description = "the namespace where to install Demeter's system"
  default     = "dmtr-system"
}

variable "cluster_name" {
  description = "a unique (hostname-safe) name to identify the cluster within the fabric"
}

variable "cloudflared_token" {
  description = "token to authenticate with cloudflared tunnel"
}

variable "provider_name" {
  description = "name of the provider"
  default     = "TxPipe.io"
}

variable "cloud_provider" {
  default = "k3d"
}

variable "cnode_v1_api_key_salt" {
  description = "shared salt used for generating API keys"
  default     = ""
}

variable "enable_cardano_node" {
  description = "enable ext-cardano-node support"
  default     = false
}

// Extensions
variable "utxorpc" {
  default     = null
  description = "Configurations for the UtxoRPC extension."
  type = object({
    operator_image_tag  = optional(string)
    extension_subdomain = string
    dns_zone            = optional(string)
    api_key_salt        = string
    namespace           = optional(string)
    networks            = optional(list(string))

    cloudflared_tunnel_id     = string
    cloudflared_tunnel_secret = string
    cloudflared_account_tag   = string
    cloudflared_image_tag     = optional(string)
    cloudflared_replicas      = optional(string)
    cloudflared_resources = optional(object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    }))
    cloudflared_tolerations = optional(list(object({
      effect   = string
      key      = string
      operator = string
      value    = optional(string)
    })))

    proxies_image_tag = optional(string)
    proxies_replicas  = optional(number)
    proxies_resources = optional(object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    }))
    proxies_tolerations = optional(list(object({
      effect   = string
      key      = string
      operator = string
      value    = optional(string)
    })))

    cells = map(object({
      tolerations = optional(list(object({
        effect   = string
        key      = string
        operator = string
        value    = optional(string)
      })))
      pvc = object({
        storage_class = string
        storage_size  = string
        volume_name   = string
      })
      instances = map(object({
        dolos_version = string
        replicas      = optional(number)
        resources = optional(object({
          limits = object({
            cpu    = string
            memory = string
          })
          requests = object({
            cpu    = string
            memory = string
          })
        }))
      }))
    }))
  })
}
