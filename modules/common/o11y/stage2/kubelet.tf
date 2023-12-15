resource "kubernetes_manifest" "servicemonitor_kubelet" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/name"      = "kubelet"
        "app.kubernetes.io/part-of"   = "demeter"
      }
      "name"      = "kubelet"
      "namespace" = var.namespace
    }
    "spec" = {
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "interval"        = "30s"
          "port"            = "https-metrics"
          "scheme"          = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "honorLabels"     = true
          "interval"        = "30s"
          "port"            = "https-metrics"
          "path"            = "/metrics/cadvisor"
          "scheme"          = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
      ]
      "jobLabel" = "k8s-app"
      "selector" = {
        "matchLabels" = {
          "k8s-app" = "kubelet"
        }
      }
      "namespaceSelector" = {
        "matchNames" = ["kube-system"]
      }
    }
  }
}
