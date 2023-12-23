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

module "aws_external_snapshoter" {
  source = "../modules/aws/external-snapshoter/stage1"
  count  = var.cloud_provider == "aws" ? 1 : 0
}

# module "metrics_server" {
#   source = "../modules/common/metrics-server/stage1"
# }

# module "cert_manager" {
#   source = "../modules/common/cert-manager/stage1"
# }

module "gateway" {
  source = "../modules/common/gateway-api/stage1"
}

module "o11y" {
  source    = "../modules/common/o11y/stage1"
  namespace = var.dmtr_namespace
}

module "dmtrd" {
  source    = "../modules/common/dmtrd/stage1"
  namespace = var.dmtr_namespace
}
