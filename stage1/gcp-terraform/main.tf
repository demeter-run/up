terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

provider "kubernetes" {
  config_path    = var.k8s_config
  config_context = var.k8s_context
}

provider "helm" {
  kubernetes {
    config_path    = var.k8s_config
    config_context = var.k8s_context
  }
}

resource "kubernetes_namespace_v1" "dmtr" {
  metadata {
    name = var.dmtr_namespace
  }
}


module "o11y" {
  source     = "../../modules/common/o11y/stage1"
  namespace  = var.dmtr_namespace
  depends_on = [kubernetes_namespace_v1.dmtr]
}

module "dmtrd" {
  source     = "../../modules/common/dmtrd/stage1"
  namespace  = var.dmtr_namespace
  depends_on = [kubernetes_namespace_v1.dmtr]
}
