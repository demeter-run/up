
locals {
  label_component = "daemon"
  label_name      = "dmtrd"
  label_version   = var.dmtrd_version
  image           = "ghcr.io/demeter-run/daemon:${var.dmtrd_version}"
}

resource "kubernetes_cluster_role_binding" "dmtrd" {
  metadata {
    name = "dmtrd"

    labels = {
      "app.kubernetes.io/component" = local.label_component
      "app.kubernetes.io/name"      = local.label_name
      "app.kubernetes.io/version"   = local.label_version
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "dmtrd"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "dmtrd"
  }
}

resource "kubernetes_cluster_role" "dmtrd" {
  metadata {
    name = "dmtrd"

    labels = {
      "app.kubernetes.io/component" = local.label_component
      "app.kubernetes.io/name"      = local.label_name
      "app.kubernetes.io/version"   = local.label_version
    }
  }

  rule {
    verbs      = ["*"]
    api_groups = ["", "apps"]
    resources  = ["*"]
  }
}

resource "kubernetes_deployment" "dmtrd" {
  metadata {
    name      = "dmtrd"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = local.label_component
      "app.kubernetes.io/name"      = local.label_name
      "app.kubernetes.io/version"   = local.label_version
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = local.label_component
        "app.kubernetes.io/name"      = local.label_name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = local.label_component
          "app.kubernetes.io/name"      = local.label_name
          "app.kubernetes.io/version"   = local.label_version
        }

        annotations = {
          "kubectl.kubernetes.io/default-container" = "main"
        }
      }

      spec {
        container {
          name  = "main"
          image = local.image

          port {
            name           = "grpc"
            container_port = 50051
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

        service_account_name            = "dmtrd"
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
  }
}

resource "kubernetes_service_account" "dmtrd" {
  metadata {
    name      = "dmtrd"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = local.label_component
      "app.kubernetes.io/name"      = local.label_name
      "app.kubernetes.io/version"   = local.label_version
    }
  }
}

resource "kubernetes_service" "dmtrd" {
  metadata {
    name      = "dmtrd"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = local.label_component
      "app.kubernetes.io/name"      = local.label_name
      "app.kubernetes.io/version"   = local.label_version
    }
  }

  spec {
    port {
      name        = "grpc"
      port        = 50051
      target_port = "grpc"
    }

    selector = {
      "app.kubernetes.io/component" = local.label_component
      "app.kubernetes.io/name"      = local.label_name
    }

    cluster_ip = "None"
  }
}

