resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  create_namespace = false
  namespace        = "kube-system"
  
  set {
    name = "clusterName"
    value = local.cluster_name
  }

  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name = "tolerations[0].operator"
    value = "Exists"
  }

  set {
    name = "tolerations[0].key"
    value = "demeter.run/compute-profile"
  }

  set {
    name = "tolerations[1].effect"
    value = "NoSchedule"
  }

  set {
    name = "tolerations[1].operator"
    value = "Exists"
  }

  set {
    name = "tolerations[1].key"
    value = "demeter.run/compute-arch"
  }

  set {
    name = "tolerations[2].effect"
    value = "NoSchedule"
  }

  set {
    name = "tolerations[2].operator"
    value = "Equal"
  }

  set {
    name = "tolerations[2].key"
    value = "demeter.run/availability-sla"
  }

  set {
    name = "tolerations[2].value"
    value = "consistent"
  }
}
