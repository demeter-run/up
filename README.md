# Demeter Up

Docs & tools to setup your Demeter cluster.

## Introduction

Anyone can run their own Demeter cluster. A Demeter cluster is in essence just a Kubernetes cluster with the following
customizations:

- Follows a specific set of conventions on how to label and taint the workers nodes
- It provides a set of shared services for common tasks (eg: observability, certificates, secrets, etc)
- It runs a custom component called `dmtrd` that contains the core business logic
- It provides a set of extensions which are K8s operator for end-user resources

This repository provides instructions and resources to help you setup your own cluster.

## Stages

The setup process is divided into stages that need to be executed in sequence. Each stage has its own README with more
fined-grained instructions. Bootstrap and Stage 0 are optional if you bring your own cluster.

| Stage     | Description                    | Docs                        |
| --------- | ------------------------------ | --------------------------- |
| Bootstrap | Cloud provider setup           | [docs](bootstrap/README.md) |
| Stage 0   | Kubernetes cluster setup       | [docs](stage0/README.md)    |
| Stage 1   | Shared services static setup   | [docs](stage1/README.md)    |
| Stage 2   | Shared services workload setup | [docs](stage2/README.md)    |
| Stage 3   | Extensions setup               | [docs](stage3/README.md)    |

### Quick Start

The fastest way to configure your cluster is using the `bin/bootstrap-cloud` script.
Out of the box, this will configure a local `k3d` cluster. To configure a default
cluster in AWS in the us-west-2 region, you only need to provide two configuration
items or GCP in us-central1.

config.yaml:

```yaml
cloud_provider: aws
```

The `bin/bootstrap-cloud` command will:

- Create the necessary AWS infrastructure for holding remote Terraform state data securely
- Configure the `backend.tf` files in stage0 through stage3 to match above
- Configure the `env.auto.tfvars` files in stage1 through stage3 to match above
- Create an EKS cluster in its own VPC in AWS

The user will need to complete the remaining steps for each of the stage1 through stage3 as
documented in each stage's README file.

### Sharing a cluster

The bootstrap process, while idempotent if configured correctly, can be destructive.
Because of this, there's an alternative script for team members to use after the
initial cluster creation is complete.

First, configure the `config.yaml` file as you would for bootstrap, but you must
also include the correct information for the Terraform bucket created by bootstrap.

config.yaml:

```yaml
cloud_provider: aws
terraform_state_bucket: abcd1234deadbeef-terraform-state
terraform_state_region: us-west-2
```

Any other custom configuration should also be shared to ensure consistency.

After this, the new team member should run the `bin/setup` command, which will
configure the `backend.tf` and `env.auto.tfvars` files in each of the stages.
