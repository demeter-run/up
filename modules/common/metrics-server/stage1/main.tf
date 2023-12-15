resource "helm_release" "metrics-server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  create_namespace = false
  namespace        = "kube-system"

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
