# Stage 0

Stage 0 of the bootstrap procedure is responsible for setting up a Kubernetes cluster compatible with Demeter.

The specific Compute infrastructure and Kubernetes control-plane out-of-scope for Demeter. We provide instructions for different common scenarios, but feel free to configure it your own way, the only strict requirement is following a specific convention for worker node taint configuration.

## Common Scenarios

| Scenario                     | Docs                              |
| ---------------------------- | --------------------------------- |
| Local development using K3d  | [README](k3d/README.md)           |
| Local development using Kind | [README](kind/README.md)          |
| Hosted cluster in AWS        | [README](aws-terraform/README.md) |
| Hosted cluster in GCP        | (coming soon)                     |
| Hosted cluster in Azure      | (coming soon)                     |


## Next Steps

You're done with stage 0. You can continue with [Stage 1](../stage1/README.md)
