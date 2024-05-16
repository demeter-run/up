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
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }
}

resource "google_container_cluster" "default" {
  # Dmtr autopilot cluster
  name = "dmtr-cluster"

  location                 = local.region
  enable_autopilot         = true
  enable_l4_ilb_subsetting = true

  network    = google_compute_network.default.id
  subnetwork = google_compute_subnetwork.default.id

  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.default.secondary_ip_range[1].range_name
  }

  deletion_protection = false
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
