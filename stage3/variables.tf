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

variable "kupo_proxy_blue_extra_annotations" {
  description = "Extra annotations for the proxy blue service"
  type        = map(string)
  default     = {}
}

variable "kupo_proxy_green_extra_annotations" {
  description = "Extra annotations for the proxy green service"
  type        = map(string)
  default     = {}
}

variable "kupo_v1_api_key_salt" {
  description = "shared salt used for generating API keys"
  default     = ""
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

variable "ogmios_cname_targets" {
  description = "list of DNS targets for the ogmios extension"
  default     = ["proxy-green.ogmios.dmtr.host", "proxy-blue.ogmios.dmtr.host"]
}

variable "ogmios_proxy_blue_extra_annotations" {
  description = "Extra annotations for the proxy blue service"
  type        = map(string)
  default     = {}
}

variable "ogmios_proxy_green_extra_annotations" {
  description = "Extra annotations for the proxy green service"
  type        = map(string)
  default     = {}
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
