resource "helm_release" "kong" {
  name       = "kong"
  namespace  = "dmtr-system"
  repository = "https://charts.konghq.com"
  chart      = "kong"
  version    = "2.37.0"

  values = [
    <<-EOT
    tolerations:
      - key: "demeter.run/compute-arch"
        operator: "Equal"
        value: "arm64"
        effect: "NoSchedule"
      - key: "demeter.run/compute-arch"
        operator: "Equal"
        value: "x86"
        effect: "NoSchedule"
      - key: "demeter.run/compute-profile"
        operator: "Equal"
        value: "admin"
        effect: "NoSchedule"
      - key: "demeter.run/availability-sla"
        operator: "Equal"
        value: "consistent"
        effect: "NoSchedule"

    env:
      database: "off"

    # Specify Kong admin API service and listener configuration
    admin:
      enabled: true
      type: ClusterIP
      labels:
        app.kubernetes.io/component: kong-admin-metrics
      http:
        enabled: true
      tls:
        enabled: false

    ingressController:
      enabled: true

    proxy:
      type: "ClusterIP"

    EOT
  ]
}

resource "kubernetes_service_v1" "kong_ping_endpoint" {
  metadata {
    name      = "kong-ping-endpoint"
    namespace = "dmtr-system"
  }
  spec {
    # This value will not be used for routing, but must resolve always.
    external_name = "kubernetes.default.svc"
    type          = "ExternalName"
  }
}

resource "kubernetes_manifest" "kong_ping_endpoint_request_termination_plugin" {
  manifest = {
    apiVersion = "configuration.konghq.com/v1"
    kind       = "KongPlugin"

    metadata = {
      name      = "kong-ping-endpoint-request-termination"
      namespace = "dmtr-system"
    }
    "plugin" = "request-termination"
    "config" = {
      "status_code" = 200
      "message"     = "PONG"
    }
  }
}

resource "kubernetes_manifest" "kong_response_transformer_plugin" {
  manifest = {
    apiVersion = "configuration.konghq.com/v1"
    kind       = "KongClusterPlugin"

    metadata = {
      name = "kong-response-transformer"
      labels = {
        "konghq.com/plugin" = "response-transformer"
        "global"            = "true"
      }
      annotations = {
        "kubernetes.io/ingress.class" = "kong"
      }
    }
    "plugin" = "response-transformer"
    "config" = {
      "add" = {
        "headers" = [
          "Rendered-By:${var.provider_name}",
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "kong_prometheus_plugin" {
  manifest = {
    apiVersion = "configuration.konghq.com/v1"
    kind       = "KongClusterPlugin"

    metadata = {
      name = "kong-prometheus"
      labels = {
        "konghq.com/plugin" = "prometheus"
        "global"            = "true"
      }
      annotations = {
        "kubernetes.io/ingress.class" = "kong"
      }
    }
    "plugin" = "prometheus"
    "config" = {
      "per_consumer"            = false
      "latency_metrics"         = true
      "bandwidth_metrics"       = true
      "status_code_metrics"     = true
      "upstream_health_metrics" = true
    }
  }
}

resource "kubernetes_ingress_v1" "kong_ping_endpoint" {
  metadata {
    name      = "kong-ping-endpoint"
    namespace = "dmtr-system"
    annotations = {
      "kubernetes.io/ingress.class" = "kong"
      "konghq.com/plugins"          = "kong-ping-endpoint-request-termination"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/ping_provider_healthcheck"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = "kong-ping-endpoint"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# Prometheus Service Monitor for Kong's Admin API
resource "kubernetes_manifest" "kong_admin_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "kong-admin-metrics"
      namespace = "dmtr-system"
      labels = {
        release = "prometheus"
        # Match labels from prometheus resource serviceMonitorSelector
        "app.kubernetes.io/component" = "o11y"
        "app.kubernetes.io/part-of"   = "demeter"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance"  = "kong"
          "app.kubernetes.io/name"      = "kong"
          "app.kubernetes.io/component" = "kong-admin-metrics"
        }
      }
      endpoints = [
        {
          port     = "kong-admin"
          interval = "30s"
          path     = "/metrics"
        }
      ]
    }
  }
}
