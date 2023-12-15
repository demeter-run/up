# Stage 0

Stage 0 of the bootstrap procedure is responsible for setting up a Kubernetes cluster compatible with Demeter.

The specific Compute infrastructure and Kubernetes control-plane out-of-scope for Demeter. We provide instructions for different common scenarios, but feel free to configure it your own way, the only strict requirement is following a specific convention for worker node taint configuration.

## Common Scenarios

- [Using Kind](kind/README.md)
- [Using AWS EKS](aws/README.md)