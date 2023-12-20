# generated using: kubectl kustomize 'github.com/kong/kubernetes-ingress-controller/config/crd?ref=v3.0.0'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.13.0
  name: ingressclassparameterses.configuration.konghq.com
spec:
  group: configuration.konghq.com
  names:
    kind: IngressClassParameters
    listKind: IngressClassParametersList
    plural: ingressclassparameterses
    singular: ingressclassparameters
  scope: Namespaced
  versions:
    - name: v1alpha1
      schema:
        openAPIV3Schema:
          description: IngressClassParameters is the Schema for the IngressClassParameters API.
          properties:
            apiVersion:
              description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources'
              type: string
            kind:
              description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds'
              type: string
            metadata:
              type: object
            spec:
              description: Spec is the IngressClassParameters specification.
              properties:
                enableLegacyRegexDetection:
                  default: false
                  description: EnableLegacyRegexDetection automatically detects if ImplementationSpecific Ingress paths are regular expression paths using the legacy 2.x heuristic. The controller adds the "~" prefix to those paths if the Kong version is 3.0 or higher.
                  type: boolean
                serviceUpstream:
                  default: false
                  description: Offload load-balancing to kube-proxy or sidecar.
                  type: boolean
              type: object
          type: object
      served: true
      storage: true
