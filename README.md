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
fined-grained instructions.

| Stage     | Description                    | Docs                        |
| --------- | ------------------------------ | --------------------------- |
| Bootstrap | Cloud provider setup           | [docs](bootstrap/README.md) |
| Stage 0   | Kubernetes cluster setup       | [docs](stage0/README.md)    |
| Stage 1   | Shared services static setup   | [docs](stage1/README.md)    |
| Stage 2   | Shared services workload setup | [docs](stage2/README.md)    |
| Stage 3   | Extensions setup               | [docs](stage3/README.md)    |

