locals {
  default_vars = yamldecode(file("../../common/defaults.yaml"))
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
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/20"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.16.0/20"
  }
}

resource "google_service_account" "default" {
  account_id   = "dmtr-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "default" {
  name = "dmtr-cluster"

  location                 = local.region
  enable_l4_ilb_subsetting = true
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.default.id
  subnetwork = google_compute_subnetwork.default.id

  ip_allocation_policy {
    stack_type                    = "IPV4"
    services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.default.secondary_ip_range[1].range_name
  }

  deletion_protection = false
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "dmtr-node-pool"
  location   = local.region
  cluster    = google_container_cluster.default.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 10
    ephemeral_storage_local_ssd_config {
      local_ssd_count = 0
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }


}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}
