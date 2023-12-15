terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

locals {
  cluster_name = "dmtr-xxx"
  k8s_config   = "~/.kube/config"
  k8s_context  = "mycontext"
}

provider "kubernetes" {
  config_path    = local.k8s_config
  config_context = local.k8s_context
}

provider "helm" {
  kubernetes {
    config_path    = local.k8s_config
    config_context = local.k8s_context
  }
}

module "aws_elb_controller" {
  source = "../modules/aws/elb-controller/stage1"
}

module "aws_external_snapshoter" {
  source = "../modules/aws/external-snapshoter/stage1"
}

module "metrics_server" {
  source = "../modules/metrics_server/stage1"
}

module "cert_manager" {
  source = "../modules/cert-manager/stage1"
}

module "gateway" {
  source = "../modules/gateway-api/stage1"
}

module "o11y" {
  source = "../modules/o11y/stage1"
}

module "dmtrd" {
  source = "../modules/dmtrd/stage1"
}
