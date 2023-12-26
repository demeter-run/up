# Stage 0 - K3d version

Instructions on how to execute the stage 0 bootstrap procedure using K3d.

## Dependencies

- K3d: https://k3d.io/

## Create a cluster

Run the following command from your terminal to create a new cluster named `dmtr`.

```bash
k3d cluster create --k3s-arg "--disable=traefik@server:0" --no-lb dmtr
```