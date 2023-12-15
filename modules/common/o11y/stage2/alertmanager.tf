resource "kubernetes_manifest" "alertmanager" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "Alertmanager"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/name"      = "alertmanager"
        "app.kubernetes.io/part-of"   = "demeter"
      }
      "name"      = "alertmanager"
      "namespace" = var.namespace
    }
    "spec" = {
      "image" = "quay.io/prometheus/alertmanager:v0.24.0"
      "podMetadata" = {
        "labels" = {
          "app.kubernetes.io/component" = "o11y"
          "app.kubernetes.io/name"      = "alertmanager"
          "app.kubernetes.io/part-of"   = "demeter"
        }
      }
      "replicas" = 2
      "resources" = {
        "limits" = {
          "cpu"    = "100m"
          "memory" = "100Mi"
        }
        "requests" = {
          "cpu"    = "4m"
          "memory" = "100Mi"
        }
      }
      "securityContext" = {
        "fsGroup"      = 2000
        "runAsNonRoot" = true
        "runAsUser"    = 1000
      }
      "tolerations" = [
        {
          "effect"   = "NoSchedule"
          "key"      = "demeter.run/compute-profile"
          "operator" = "Exists"
        },
        {
          "effect"   = "NoSchedule"
          "key"      = "demeter.run/compute-arch"
          "operator" = "Exists"
        },
        {
          "effect"   = "NoSchedule"
          "key"      = "demeter.run/availability-sla"
          "operator" = "Equal"
          "value"    = "consistent"
        }
      ]
      "version" = "0.24.0"
    }
  }
}
