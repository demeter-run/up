resource "helm_release" "postgres-operator" {
  name             = "postgres-operator"
  chart            = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator/postgres-operator-1.10.0.tgz"
  create_namespace = true
  namespace        = "postgres-operator"

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
    value = "Equal"
  }

  set {
    name  = "tolerations[1].key"
    value = "demeter.run/compute-arch"
  }

  set {
    name  = "tolerations[1].value"
    value = "x86"
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
