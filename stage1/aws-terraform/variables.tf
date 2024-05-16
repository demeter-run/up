variable "cloud_provider" {
  description = "the cloud provider being used to host the cluster"
  type        = string

  validation {
    condition     = can(regex("^(aws|gcp|azure|kind|k3d|other)$", var.cloud_provider))
    error_message = "The environment must be either 'aws', 'gcp', 'azure', 'kind', 'k3d' or 'other'"
  }
}

variable "k8s_config" {
  description = "the location of the k8s configuration"
  default     = "~/.kube/config"
}

variable "k8s_context" {
  description = "the name of the k8s context as defined in the kube config file"
}

variable "aws_eks_cluster_name" {
  description = "the name of the AWS EKS cluster"
  default     = null
}

variable "dmtr_namespace" {
  description = "the namespace where to install Demeter's system"
  default     = "dmtr-system"
}
