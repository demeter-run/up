
resource "kubernetes_cluster_role_binding" "prometheus_operator" {
  metadata {
    name = "prometheus-operator"

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "prometheus-operator"
      "app.kubernetes.io/version"   = "0.63.0"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "prometheus-operator"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prometheus-operator"
  }
}

resource "kubernetes_cluster_role" "prometheus_operator" {
  metadata {
    name = "prometheus-operator"

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "prometheus-operator"
      "app.kubernetes.io/version"   = "0.63.0"
    }
  }

  rule {
    verbs      = ["*"]
    api_groups = ["monitoring.coreos.com"]
    resources  = ["alertmanagers", "alertmanagers/finalizers", "alertmanagers/status", "alertmanagerconfigs", "prometheuses", "prometheuses/finalizers", "prometheuses/status", "thanosrulers", "thanosrulers/finalizers", "servicemonitors", "podmonitors", "probes", "prometheusrules"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["apps"]
    resources  = ["statefulsets"]
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
  }

  rule {
    verbs      = ["list", "delete"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["get", "create", "update", "delete"]
    api_groups = [""]
    resources  = ["services", "services/finalizers", "endpoints"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }
}

resource "kubernetes_deployment" "prometheus_operator" {
  metadata {
    name      = "prometheus-operator"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "prometheus-operator"
      "app.kubernetes.io/version"   = "0.63.0"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/name"      = "prometheus-operator"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "controller"
          "app.kubernetes.io/name"      = "prometheus-operator"
          "app.kubernetes.io/version"   = "0.63.0"
        }

        annotations = {
          "kubectl.kubernetes.io/default-container" = "prometheus-operator"
        }
      }

      spec {
        container {
          name  = "prometheus-operator"
          image = "quay.io/prometheus-operator/prometheus-operator:v0.63.0"
          args  = ["--kubelet-service=kube-system/kubelet", "--prometheus-config-reloader=quay.io/prometheus-operator/prometheus-config-reloader:v0.63.0"]

          port {
            name           = "http"
            container_port = 8080
          }

          resources {
            limits = {
              memory = "500Mi"
            }

            requests = {
              cpu    = "250m"
              memory = "500Mi"
            }
          }

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            read_only_root_filesystem = true
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name            = "prometheus-operator"
        automount_service_account_token = true

        security_context {
          run_as_user     = 65534
          run_as_non_root = true
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Exists"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-arch"
          operator = "Equal"
          value    = "arm64"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "demeter.run/availability-sla"
          operator = "Equal"
          value    = "consistent"
        }

        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "arm64"
        }
      }
    }
  }
}

resource "kubernetes_service_account" "prometheus_operator" {
  metadata {
    name      = "prometheus-operator"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "prometheus-operator"
      "app.kubernetes.io/version"   = "0.63.0"
    }
  }
}

resource "kubernetes_service" "prometheus_operator" {
  metadata {
    name      = "prometheus-operator"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "prometheus-operator"
      "app.kubernetes.io/version"   = "0.63.0"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }

    selector = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "prometheus-operator"
    }

    cluster_ip = "None"
  }
}
