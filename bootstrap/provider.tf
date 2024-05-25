provider "google" {
  project = local.project_id
  region  = local.region
}

# Configure our AWS provider
# provider "aws" {
#   region = "us-east-1"
# }
