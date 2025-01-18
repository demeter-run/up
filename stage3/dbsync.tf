locals {
  namespace = var.namespace_cardano_data
  # cloud_provider     = var.cloud_provider
  cloud_provider     = "gcp"
  operator_image_tag = "443f23c61f3a43b69e1ad2a776ef45b50481a6a6"
  metrics_delay      = 60
  # All dcu per second are referenced in bootstrap/feature/operator.tf
  dcu_per_second = {
    "mainnet"        = "10"
    "preprod"        = "5"
    "preview"        = "5"
    "sanchonet"      = "5"
    "vector-testnet" = "5"
    "prime-testnet"  = "5"
  }
  postgres_secret_name         = "postgres.dbsync-cluster.credentials.postgresql.acid.zalan.do"
  postgres_password            = var.dbsync_postgres_password
  pgbouncer_server_crt         = var.dbsync_pgbouncer_server_crt
  pgbouncer_server_key         = var.dbsync_pgbouncer_server_key
  pgbouncer_reloader_image_tag = "c13dff359c44efd7b86502ff1aec3c815b6584e5"
  operator_resources = {
    limits = {
      cpu    = "1"
      memory = "2Gi"
    }
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }
  pgbouncer_image_tag          = "1.21.0"
  pgbouncer_auth_user_password = "changeme"

  processed_cells = {
    cell1 = {
      # PVC for postgres
      pvc = {
        storage_size = "50Gi"
        # TODO ?? why immediate if not named
        storage_class_name = "hyperdisk-balanced"
        access_mode        = "ReadWriteOnce"
        // Optional parameters name translates to db_volume_claim to pvc name
        name = "cell1-pvc"
      }
      postgres = {
        image_tag             = "17"
        topology_zone         = "default"
        is_blockfrost_backend = false
        config_name           = "preview"
        topology_zone         = "us-central1-a"
        resources = {
          limits = {
            cpu    = "1"
            memory = "2Gi"
          }
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
        }
        tolerations = [
          {
            effect   = "NoSchedule"
            key      = "demeter.run/availability-sla"
            operator = "Equal"
            value    = "consistent"
          },
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
            key      = "kubernetes.io/arch"
            operator = "Equal"
            value    = "arm64"
          }
        ]
      }
      # pgbouncer = {
      #   replicas             = 1
      #   postgres_secret_name = local.postgres_secret_name
      #   tolerations = [
      #     {
      #       effect   = "NoSchedule"
      #       key      = "demeter.run/availability-sla"
      #       operator = "Equal"
      #       value    = "consistent"
      #     },
      #     {
      #       effect   = "NoSchedule"
      #       key      = "demeter.run/compute-profile"
      #       operator = "Equal"
      #       value    = "general-purpose"
      #     },
      #     {
      #       effect   = "NoSchedule"
      #       key      = "demeter.run/compute-arch"
      #       operator = "Equal"
      #       value    = "x86"
      #     }
      #   ]
      # }
      instances = {
        instance1 = {
          network               = "preview"
          dbsync_image          = "ghcr.io/blinklabs-io/cardano-db-sync"
          dbsync_image_tag      = "13.6.0.4"
          node_n2n_tcp_endpoint = "node-preview-stable.ext-nodes-m1.svc.cluster.local:3307"
          release               = "not-set"
          sync_status           = "syncing"
          enable_postgrest      = false
          # Optional parameters
          empty_args    = false
          custom_config = true
          # network_env_var       = false
          # topology_zone         = ""
          postgres_secret_name   = local.postgres_secret_name
          postgres_instance_name = "dbsync-cluster.cardano-data.svc.cluster.local"
          dbsync_volume = {
            size          = "50Gi"
            storage_class = "hyperdisk-balanced"
          }
          dbsync_resources = {
            requests = {
              "cpu"    = "500m"
              "memory" = "1Gi"
            }
            limits = {
              "cpu"    = "2"
              "memory" = "8Gi"
            }
          }
          tolerations = [
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
        }
      }
    }
  }
}

# module "ext_cardano_dbsync_crds" {
#   source   = "git::https://github.com/demeter-run/ext-cardano-dbsync-serverless.git//bootstrap/crds"
#   for_each = toset(var.enable_cardano_dbsync ? ["global"] : [])
# }

module "ext_cardano_dbsync" {
  # TODO: remove ref to feat/add-gcp-support when merged
  source                       = "git::https://github.com/blinklabs-io/demeter-ext-cardano-dbsync-serverless.git//bootstrap?ref=feat/add-gcp-support"
  for_each                     = toset([for n in toset(["v1"]) : n if var.enable_cardano_dbsync])
  namespace                    = local.namespace
  cloud_provider               = local.cloud_provider
  operator_image_tag           = local.operator_image_tag
  metrics_delay                = local.metrics_delay
  dcu_per_second               = local.dcu_per_second
  postgres_secret_name         = local.postgres_secret_name
  postgres_password            = local.postgres_password
  pgbouncer_server_crt         = local.pgbouncer_server_crt
  pgbouncer_server_key         = local.pgbouncer_server_key
  pgbouncer_reloader_image_tag = local.pgbouncer_reloader_image_tag
  operator_resources           = local.operator_resources
  enable_postgres              = false
  enable_pgbouncer             = false
  pgbouncer_image_tag          = local.pgbouncer_image_tag
  pgbouncer_auth_user_password = local.pgbouncer_auth_user_password
  cells                        = local.processed_cells
}
