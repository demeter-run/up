
resource "kubernetes_deployment" "cloudflared" {
  metadata {
    name      = "cloudflared"
    namespace = var.dmtr_namespace

    labels = {
      "app.kubernetes.io/name" = "cloudflared"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "cloudflared"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "cloudflared"
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
            "--protocol",
            "http2",
            "--metrics",
            "0.0.0.0:60123",
            "run",
            "--token",
            var.cloudflared_token
          ]

          port {
            container_port = 60123
            protocol       = "TCP"
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

resource "kubernetes_service" "cloudflared_metrics" {
  metadata {
    name      = "cloudflared-metrics"
    namespace = var.dmtr_namespace
    labels = {
      "app.kubernetes.io/name" = "cloudflared-metrics"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "cloudflared"
    }

    port {
      name        = "metrics"
      port        = 60123
      target_port = 60123
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "cloudflared_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "cloudflared-metrics-monitor"
      namespace = "dmtr-system"
      labels = {
        app = "cloudflared"
        # Match labels from prometheus resource serviceMonitorSelector
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/part-of"   = "demeter"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "cloudflared-metrics"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          interval = "30s"
          path     = "/metrics"
          scheme   = "http"
        }
      ]
    }
  }
}
