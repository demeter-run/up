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

# External DNS
variable "enable_external_dns" {
  description = "enable external-dns support"
  default     = false
}

variable "cloudflare_token" {
  type        = string
  sensitive   = true
  description = <<EOF
    Cloudflare API token with permissions to manage DNS records.
EOF
}

variable "dns_endpoint_zone" {
  description = "The DNS zone for the external-dns"
  type        = string
  default     = "dmtr.host"
}

variable "enable_kupo_dns_endpoint" {
  description = "Toggle DNS configuration for Kupo endpoint"
  type        = bool
  default     = false
}

variable "kupo_dns_endpoint_per_network" {
  description = "Map of network names to DNS and CNAME configurations for Kupo endpoint"
  type = map(object({
    dns   = string
    cname = string
  }))
  default = {
    mainnet = {
      dns   = "mainnet.kupo.dmtr.host",
      cname = "proxy-green.mainnet.kupo.dmtr.host"
    }
    preprod = {
      dns   = "preprod.kupo.dmtr.host",
      cname = "proxy-green.preprod.kupo.dmtr.host"
    }
    preview = {
      dns   = "preview.kupo.dmtr.host",
      cname = "proxy-green.preview.kupo.dmtr.host"
    }
  }
}

variable "enable_node_dns_endpoint" {
  description = "Toggle DNS configuration for Node endpoint"
  type        = bool
  default     = false
}

variable "node_cname_targets" {
  description = "List of CNAME record targets for the Node endpoint"
  type        = list(string)
  default     = ["example.dmtr.com"] // replace with actual target
}

variable "enable_ogmios_dns_endpoint" {
  description = "Toggle DNS configuration for Ogmios endpoint"
  type        = bool
  default     = false
}

variable "ogmios_cname_targets" {
  description = "List of CNAME record targets for the ogmios extension"
  default     = ["example.dmtr.host"] // replace with actual target
}

variable "ogmos_topology_az1" {
  description = "node affinity match_expressions for node topology zone 1 instance"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = [
    {
      key      = "topology.kubernetes.io/zone"
      operator = "In"
      values   = ["us-central1-a"]
    }
  ]
}

# Cardano Node extension
variable "enable_cardano_node" {
  description = "enable ext-cardano-node support"
  default     = false
}

variable "node_proxy_blue_extra_annotations" {
  description = "Extra annotations for the proxy blue service"
  type        = map(string)
  default     = {}
}

variable "node_proxy_green_extra_annotations" {
  description = "Extra annotations for the proxy blue service"
  type        = map(string)
  default     = {}
}

variable "node_topology_az1" {
  description = "node affinity match_expressions for node topology zone 1 instance"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = [
    {
      key      = "topology.kubernetes.io/zone"
      operator = "In"
      values   = ["us-central1-a"]
    }
  ]
}

variable "storage_size_mainnet" {
  description = "size of the storage for the mainnet"
  default     = "500Gi"
}

variable "storage_class_name_mainnet" {
  description = "name of the storage class for the mainnet"
  default     = "pd-ssd"
}

variable "toleration_k8s_arch_mainnet" {
  description = "toleration for the k8s arch"
  default     = "amd64"
}

variable "storage_size_preprod" {
  description = "size of the storage for the preprod"
  default     = "50Gi"
}

variable "storage_class_name_preprod" {
  description = "name of the storage class for the preprod"
  default     = "pd-ssd"
}

variable "toleration_k8s_arch_preprod" {
  description = "toleration for the k8s arch"
  default     = "amd64"
}

variable "storage_size_preview" {
  description = "size of the storage for the preview"
  default     = "50Gi"
}

variable "storage_class_name_preview" {
  description = "name of the storage class for the preview"
  default     = "pd-ssd"
}

variable "toleration_k8s_arch_preview" {
  description = "toleration for the k8s arch"
  default     = "amd64"
}

# Kupo extension
variable "enable_cardano_kupo" {
  description = "enable ext-cardano-kupo support"
  default     = false
}

variable "kupo_proxy_blue_extra_annotations_by_network" {
  description = <<EOT
A map where keys are network names (only those defined in the "networks" variable)
and values are maps of extra annotations for the blue proxy service specific
to that network.
EOT
  type        = map(map(string))
  default     = {}
}

variable "kupo_proxy_green_extra_annotations_by_network" {
  description = <<EOT
A map where keys are network names (only those defined in the "networks" variable)
and values are maps of extra annotations for the green proxy service specific
to that network.
EOT
  type        = map(map(string))
  default     = {}
}

variable "kupo_v1_api_key_salt" {
  description = "shared salt used for generating API keys"
  default     = ""
}

variable "kupo_v1_cell1_preview_node_affinity" {
  description = "node affinity match_expressions for kupo cell1 preview instance"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = [
    {
      key      = "cloud.google.com/gke-nodepool"
      operator = "In"
      values   = ["co-gp-arm64-az1"]
    }
  ]
}

variable "kupo_v1_cell2_preprod_node_affinity" {
  description = "node affinity match_expressions for kupo cell2 preprod instance"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = [
    {
      key      = "cloud.google.com/gke-nodepool"
      operator = "In"
      values   = ["co-gp-arm64-az1"]
    }
  ]
}

variable "kupo_v1_cell3_mainnet_node_affinity" {
  description = "node affinity match_expressions for kupo cell3 mainnet instance"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = [
    {
      key      = "cloud.google.com/gke-nodepool"
      operator = "In"
      values   = ["co-gp-arm64-az1"]
    }
  ]
}

variable "kupo_v1_cell4_mainnet_node_affinity" {
  description = "node affinity match_expressions for kupo cell4 mainnet instance"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = [
    {
      key      = "cloud.google.com/gke-nodepool"
      operator = "In"
      values   = ["co-gp-arm64-az2"]
    }
  ]
}

variable "kupo_v1_storage_size_preview" {
  description = "size of the storage for the kupo extension"
  default     = "50Gi"
}

variable "kupo_v1_storage_size_preprod" {
  description = "size of the storage for the kupo extension"
  default     = "50Gi"
}

variable "kupo_v1_storage_size_mainnet" {
  description = "size of the storage for the kupo extension"
  default     = "50Gi"
}

variable "kupo_v1_storage_class_name" {
  description = "name of the storage class for the kupo extension"
  default     = "hyperdisk-balanced-immediate"
}

variable "kupo_v1_cell4_storage_class_name" {
  description = "name of the storage class for the kupo cell4 mainnet instance"
  default     = "hyperdisk-balanced"
}

variable "kupo_v1_tolerations" {
  description = "Tolerations for Kupo instances"
  type = list(object({
    effect   = string
    key      = string
    operator = string
    value    = string
  }))
  default = [
    {
      effect   = "NoSchedule"
      key      = "demeter.run/compute-profile"
      operator = "Equal"
      value    = "general-purpose"
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
}

# Ogmios extension
variable "ogmios_v1_api_key_salt" {
  description = "shared salt used for generating API keys"
  default     = ""
}

variable "enable_cardano_ogmios" {
  description = "enable ext-cardano-ogmios support"
  default     = false
}

variable "ogmios_dns_zone" {
  description = "the DNS zone for the ogmios extension"
  default     = "dmtr.host"
}

variable "ogmios_proxy_blue_extra_annotations_by_network" {
  description = <<EOT
A map where keys are network names (only those defined in the "networks" variable)
and values are maps of extra annotations for the blue proxy service specific
to that network.
EOT
  type        = map(map(string))
  default     = {}
}

variable "ogmios_proxy_green_extra_annotations_by_network" {
  description = <<EOT
A map where keys are network names (only those defined in the "networks" variable)
and values are maps of extra annotations for the green proxy service specific
to that network.
EOT
  type        = map(map(string))
  default     = {}
}

variable "ogmios_dns_endpoint_per_network" {
  description = "Map of network names to DNS and CNAME configurations for Ogmios endpoint"
  type = map(object({
    dns   = string
    cname = string
  }))
  default = {
    mainnet = {
      dns   = "mainnet.ogmios.dmtr.host",
      cname = "proxy-green.mainnet.ogmios.dmtr.host"
    }
    preprod = {
      dns   = "preprod.ogmios.dmtr.host",
      cname = "proxy-green.preprod.ogmios.dmtr.host"
    }
    preview = {
      dns   = "preview.ogmios.dmtr.host",
      cname = "proxy-green.preview.ogmios.dmtr.host"
    }
  }
}

# Postgres cluster
variable "enable_postgres_operator" {
  description = "enable postgres operator"
  default     = false
}

# Ensure the postgres operator is enabled to provide the necessary CRDs
# before creating the postgres cluster
variable "enable_postgres_cluster" {
  description = "enable postgres cluster"
  default     = false
}

# UtxoRPC extension
variable "enable_cardano_utxorpc" {
  description = "enable ext-cardano-utxorpc support"
  default     = false
}

variable "utxorpc" {
  description = "Configuration for the UtxoRPC extension"
  default     = {}
}
