resource "helm_release" "grafana_tempo" {
  name             = "grafana-tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo"
  create_namespace = false
  namespace        = "demeter-system"

  set {
    name  = "tempo.reportingEnabled"
    value = "false"
  }

  set {
    name = "tempo.retention"
    value = "168h"
  }

  set {
    name  = "tempo.persistence.enabled"
    value = "true"
  }

  set {
    name  = "tempo.persistence.size"
    value = "10Gi"
  }

  set {
    name  = "tempo.persistence.storageClass"
    value = "gp3"
  }

  set {
    name  = "tempo.persistence.accessModes[0]"
    value = "ReadWriteOnce"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "tolerations[0].key"
    value = "demeter.run/compute-profile"
  }

  set {
    name  = "tolerations[1].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[1].operator"
    value = "Exists"
  }

  set {
    name  = "tolerations[1].key"
    value = "demeter.run/compute-arch"
  }

  set {
    name  = "tolerations[2].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[2].operator"
    value = "Equal"
  }

  set {
    name  = "tolerations[2].key"
    value = "demeter.run/availability-sla"
  }

  set {
    name  = "tolerations[2].value"
    value = "consistent"
  }
}
