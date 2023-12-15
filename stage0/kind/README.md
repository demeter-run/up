# Stage 0 - Kind version

Instructions on how to execute the stage 0 bootstrap procedure using Kind (Kubernetes in Docker).

## Dependencies

- Kind: https://kind.sigs.k8s.io/

## Create a cluster

Run the following command from your terminal to create a new cluster named `dmtr`.

```bash
kind create cluster --name dmtr
```
