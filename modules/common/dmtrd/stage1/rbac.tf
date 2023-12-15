variable "namespace" {
  default = "demeter-system"
}

resource "kubernetes_cluster_role" "cluster-role" {
  metadata {
    name = var.namespace
  }

  rule {
    api_groups = ["", "rbac.authorization.k8s.io", "apps", "networking.k8s.io", "metrics.k8s.io", "batch", "demeter.run", "events.k8s.io", "gateway.networking.k8s.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster-role-binding" {
  metadata {
    name = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.namespace
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.namespace
  }
}
