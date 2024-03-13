# Example

An overview of the example files in this directory.

## Example manifests

frontend.yaml - is an example of manifests for the frontend service

## Use Ingress routing

Use manifests:

- ingress.yaml
- service.yaml

## Use Gateway routing

Use manifests:

- gateway.yaml
- httproute.yaml
- service.yaml

There is an `gateway.yaml` file in the examples folder. It contains the manifests for the KongIngressController and the Gateway API. To use `gateway.yaml`, you need to install the Gateway API CRDs before you install the KongIngressController.

Install Gateway API CRDs for KongIngressController

[Gateway API](https://docs.konghq.com/kubernetes-ingress-controller/3.1.x/guides/services/http/) Kong guides

Install the Gateway API CRDs before installing Kong Ingress Controller.

```bash
 kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```
