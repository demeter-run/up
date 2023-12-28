
resource "kubernetes_deployment" "cloudfared" {
  metadata {
    name      = "cloudfared"
    namespace = var.dmtr_namespace

    labels = {
      "app.kubernetes.io/name" = "cloudfared"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "cloudfared"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "cloudfared"
        }

        annotations = {
          "kubectl.kubernetes.io/default-container" = "main"
        }
      }

      spec {
        container {
          name = "main"

          image = "cloudflare/cloudflared:latest"

          args = [
            "tunnel",
            "--no-autoupdate",
            "run",
            "--token",
            var.cloudfared_token
          ]

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
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        automount_service_account_token = false

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
