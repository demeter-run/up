resource "kubernetes_deployment" "snapshot_controller" {
  metadata {
    name      = "snapshot-controller"
    namespace = "kube-system"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "snapshot-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "snapshot-controller"
        }
      }

      spec {
        container {
          name              = "snapshot-controller"
          image             = "registry.k8s.io/sig-storage/snapshot-controller:v6.1.0"
          args              = ["--v=5", "--leader-election=true"]
          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "snapshot-controller"

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Exists"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-arch"
          operator = "Exists"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/availability-sla"
          operator = "Equal"
          value    = "consistent"
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
      }
    }

    min_ready_seconds = 15
  }

  depends_on = [
    kubernetes_service_account.snapshot_controller
  ]
}


resource "kubernetes_service_account" "snapshot_controller" {
  metadata {
    name      = "snapshot-controller"
    namespace = "kube-system"
  }
}


resource "kubernetes_cluster_role" "snapshot_controller_runner" {
  metadata {
    name = "snapshot-controller-runner"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["persistentvolumes"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["list", "watch", "create", "update", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "update", "delete", "patch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents/status"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update", "patch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots"]
  }

  rule {
    verbs      = ["update", "patch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots/status"]
  }
}

resource "kubernetes_cluster_role_binding" "snapshot_controller_role" {
  metadata {
    name = "snapshot-controller-role"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "snapshot-controller"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "snapshot-controller-runner"
  }

  depends_on = [
    kubernetes_cluster_role.snapshot_controller_runner,
    kubernetes_service_account.snapshot_controller
  ]
}

resource "kubernetes_role" "snapshot_controller_leaderelection" {
  metadata {
    name      = "snapshot-controller-leaderelection"
    namespace = "kube-system"
  }

  rule {
    verbs      = ["get", "watch", "list", "delete", "update", "create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

resource "kubernetes_role_binding" "snapshot_controller_leaderelection" {
  metadata {
    name      = "snapshot-controller-leaderelection"
    namespace = "kube-system"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "snapshot-controller"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "snapshot-controller-leaderelection"
  }
}

