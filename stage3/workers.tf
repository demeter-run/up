# TODO: this should be unified into a single module

locals {
  ext_workers_namespace = "ext-workers-v0"
}

resource "kubernetes_namespace_v1" "ext_workers" {
  metadata {
    name = local.ext_workers_namespace
  }
}

module "workers_crds" {
  source = "git::https://github.com/demeter-run/workloads.git//bootstrap/crds"
}

module "workers_configs" {
  source     = "git::https://github.com/demeter-run/workloads.git//bootstrap/configs"
  namespace  = local.ext_workers_namespace
  depends_on = [kubernetes_namespace_v1.ext_workers]
}

module "workers_operator" {
  depends_on    = [helm_release.kong, kubernetes_namespace_v1.ext_workers]
  source        = "git::https://github.com/demeter-run/workloads.git//bootstrap/operator"
  namespace     = local.ext_workers_namespace
  cluster_name  = var.cluster_name
  cluster_alias = var.cluster_name # TODO: revisit this concept
  image_tag     = "2399faed49945e6f391a3e05c36d00704a65e287"
}

