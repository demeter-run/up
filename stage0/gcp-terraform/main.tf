locals {
  default_vars = yamldecode(file("../../common/defaults-gcp.yaml"))
  config_vars  = try(yamldecode(file("../../config.yaml")), {})
  project_id   = try(local.config_vars.terraform_project_id, "")
  region       = try(local.config_vars.region, local.default_vars.region)

  name = try(
    local.config_vars.cluster_name,
    local.default_vars.cluster_name,
  )

  azs = try(
    local.config_vars.azs,
    local.default_vars.azs,
  )
  vpc_cidr = try(
    local.config_vars.vpc_cidr,
    local.default_vars.vpc_cidr,
  )
  node_vars = try(
    local.config_vars.managed_node_groups,
    local.default_vars.managed_node_groups,
  )

  cluster_version = "1.27"

  tags = {
    Name = local.name
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}

resource "google_compute_network" "default" {
  name = "dmtr-network"

  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "default" {
  name = "dmtr-subnetwork"

  ip_cidr_range = local.vpc_cidr
  region        = local.region

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"

  network = google_compute_network.default.id
  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "192.168.16.0/20"
  }
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/20"
  }
}

# Defined in bootstrap/gcp-terraform/gcp-terraform.tf
data "google_service_account" "existing" {
  account_id = "terraform-runner"
  project    = local.project_id
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = local.project_id
  name                       = local.name
  region                     = local.region
  zones                      = local.azs
  network                    = google_compute_network.default.name
  subnetwork                 = google_compute_subnetwork.default.name
  ip_range_pods              = "pod-range"
  ip_range_services          = "services-range"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  dns_cache                  = false
  deletion_protection        = false

  node_pools = [for np in local.node_vars : {
    name               = np.name
    machine_type       = np.instance_type
    node_locations     = replace(np.availability_zones, "/^[a-z]+-[a-z]+[0-9]+/", "${local.region}")
    min_count          = np.min_size
    max_count          = np.max_size
    disk_size_gb       = np.disk_size_gb
    disk_type          = try(np.disk_type, "pd-ssd")
    auto_repair        = true
    auto_upgrade       = true
    service_account    = data.google_service_account.existing.email
    preemptible        = false
    initial_node_count = np.desired_capacity
  }]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = merge(
    {
      all = {}
    },
    { for np in local.node_vars : np.name => np.labels }
  )

  node_pools_metadata = {
    all = {}

  }

  node_pools_taints = merge(
    {
      all = []
    },
    { for np in local.node_vars : np.name => np.taints }
  )

  node_pools_tags = {
    all = []
  }
}


data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}
