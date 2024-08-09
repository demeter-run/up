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

variable "utxorpc_api_key_salt" {
  type        = string
  description = "Salt used to generate auth tokens for UtxoRPC. Soon to be deprecated."
}

variable "utxorpc_cloudflared_tunnel_id" {
  type        = string
  description = "ID for the CloudFlare tunnel used to route traffic."
}

variable "utxorpc_cloudflared_tunnel_secret" {
  type        = string
  description = "TunnelSecret for the CloudFlare tunnel used to route traffic, found on credentials json."
}

variable "utxorpc_cloudflared_account_tag" {
  type        = string
  description = "AccountTag for the CloudFlare tunnel used to route traffic, found on credentials json."
}

variable "utxorpc_extension_subdomain" {
  type        = string
  description = "Subdomain of the utxorpc.cloud where this extension is hosted."
}

variable "utxorpc_dns_zone" {
  type        = string
  default     = "utxorpc.cloud"
  description = "DNS zone for UtxoRPC extension."
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
