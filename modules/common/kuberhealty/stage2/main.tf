resource "helm_release" "kuberhealthy" {
  name             = "kuberhealthy"
  repository       = "https://kuberhealthy.github.io/kuberhealthy/helm-repos"
  chart            = "kuberhealthy"
  create_namespace = false
  namespace        = "demeter-system"

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.serviceMonitor.additionalLabels.app\\.kubernetes\\.io/part-of"
    value = "demeter"
  }

  set {
    name  = "prometheus.serviceMonitor.additionalLabels.app\\.kubernetes\\.io/component"
    value = "o11y"
  }

  set {
    name  = "prometheus.serviceMonitor.namespace"
    value = "demeter-system"
  }

  set {
    name  = "deployment.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "deployment.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "deployment.tolerations[0].key"
    value = "demeter.run/compute-profile"
  }

  set {
    name  = "deployment.tolerations[1].effect"
    value = "NoSchedule"
  }

  set {
    name  = "deployment.tolerations[1].operator"
    value = "Equal"
  }

  set {
    name  = "deployment.tolerations[1].key"
    value = "demeter.run/compute-arch"
  }

  set {
    name  = "deployment.tolerations[1].value"
    value = "x86"
  }

  set {
    name  = "deployment.tolerations[2].effect"
    value = "NoSchedule"
  }

  set {
    name  = "deployment.tolerations[2].operator"
    value = "Equal"
  }

  set {
    name  = "deployment.tolerations[2].key"
    value = "demeter.run/availability-sla"
  }

  set {
    name  = "deployment.tolerations[2].value"
    value = "consistent"
  }

  set {
    name  = "check.daemonset.enabled"
    value = "false"
  }

  set {
    name  = "check.deployment.enabled"
    value = "false"
  }

  set {
    name  = "check.dnsInternal.enabled"
    value = "false"
  }
}


