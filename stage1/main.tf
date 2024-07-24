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

module "aws_elb_controller" {
  source       = "../modules/aws/elb-controller/stage1"
  count        = var.cloud_provider == "aws" ? 1 : 0
  cluster_name = var.aws_eks_cluster_name
}

module "aws_storage_classes" {
  source = "../modules/aws/storage-classes/stage1"
  count  = var.cloud_provider == "aws" ? 1 : 0
}

module "gcp_storage_classes" {
  source = "../modules/gcp/storage-classes/stage1"
  count  = var.cloud_provider == "gcp" ? 1 : 0
}

module "kind_storage_classes" {
  source = "../modules/kind/storage-classes/stage1"
  count  = var.cloud_provider == "kind" ? 1 : 0
}

module "k3d_storage_classes" {
  source = "../modules/k3d/storage-classes/stage1"
  count  = var.cloud_provider == "k3d" ? 1 : 0
}

# module "metrics_server" {
#   source = "../modules/common/metrics-server/stage1"
# }

module "cert_manager" {
  source = "../modules/common/cert-manager/stage1"
}

module "o11y" {
  source     = "../modules/common/o11y/stage1"
  namespace  = var.dmtr_namespace
  depends_on = [kubernetes_namespace_v1.dmtr]
}
