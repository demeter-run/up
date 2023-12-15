resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "demeter:prometheus"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/metrics", "services", "endpoints", "pods"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs             = ["get"]
    non_resource_urls = ["/metrics", "/metrics/cadvisor"]
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "demeter:prometheus"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "demeter:prometheus"
  }
}
