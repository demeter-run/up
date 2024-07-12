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

variable "dmtrd_version" {
  description = "version of the Demeter daemon to deploy"
  default     = "0.1.0-alpha.2"
}

// Ingress class to use for cert-manager
variable "cloud_provider" {
  default = "gcp"
}

// Email to use for the ACME account
variable "acme_account_email" {
  default = "something@example.com"
}
