resource "helm_release" "postgres_operator" {
  for_each         = toset([for n in toset(["v1"]) : n if var.enable_postgres_operator])
  name             = "postgres-operator"
  chart            = "postgres-operator"
  repository       = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator/"
  namespace        = "postgres-operator"
  create_namespace = true
  values = [
    yamlencode({
      image = {
        repository = "ghcr.io/zalando/postgres-operator"
      }
      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }

      tolerations = [
        {
          key      = "demeter.run/compute-profile"
          operator = "Equal"
          value    = "general-purpose"
          effect   = "NoSchedule"
        },
        {
          key      = "demeter.run/compute-arch"
          operator = "Equal"
          value    = "arm64"
          effect   = "NoSchedule"
        },
        {
          key      = "demeter.run/availability-sla"
          operator = "Equal"
          value    = "consistent"
          effect   = "NoSchedule"
        },
        {
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "arm64"
          effect   = "NoSchedule"
        }
      ]
    })
  ]
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "null_resource" "ensure_namespace_postgres" {
  depends_on = [kubernetes_namespace.postgres]
}

resource "kubernetes_manifest" "postgres_cluster_dbsync" {
  for_each   = toset([for n in toset(["v1"]) : n if var.enable_postgres_cluster])
  depends_on = [helm_release.postgres_operator]

  manifest = {
    "apiVersion" = "acid.zalan.do/v1"
    "kind"       = "postgresql"
    "metadata" = {
      "name"      = "dbsync-cluster"
      "namespace" = "postgres"
    }
    "spec" = {
      "teamId" = "dbsync"
      "postgresql" = {
        "version" = "17"
      }
      "numberOfInstances"        = 1
      "enableMasterLoadBalancer" = true
      "resources" = {
        "requests" = {
          "cpu"    = "250m"
          "memory" = "250Mi"
        }
        "limits" = {
          "cpu"    = "1"
          "memory" = "1Gi"
        }
      }
      "users" = {
        "dbsync_owner" = ["superuser", "createdb"]
        "dbsync_app"   = []
      }
      "databases" = {
        "dbsync_preview" = "dbsync_owner"
        "dbsync_preprod" = "dbsync_owner"
        "dbsync_mainnet" = "dbsync_owner"
      }
      "tolerations" = [
        {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-profile"
          operator = "Equal"
          value    = "general-purpose"
        },
        {
          effect   = "NoSchedule"
          key      = "demeter.run/compute-arch"
          operator = "Equal"
          value    = "arm64"
        },
        {
          effect   = "NoSchedule"
          key      = "demeter.run/availability-sla"
          operator = "Equal"
          value    = "consistent"
        },
        {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "arm64"
        }
      ]
      "volume" = {
        "size"         = "55Gi"
        "storageClass" = "hyperdisk-balanced"
      }
    }
  }
}
