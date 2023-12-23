#
# config/crd/experimental/gateway.networking.k8s.io_referencegrants.yaml
#
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    api-approved.kubernetes.io: https://github.com/kubernetes-sigs/gateway-api/pull/2466
    gateway.networking.k8s.io/bundle-version: v1.0.0
    gateway.networking.k8s.io/channel: experimental
  name: referencegrants.gateway.networking.k8s.io
spec:
  group: gateway.networking.k8s.io
  names:
    categories:
      - gateway-api
    kind: ReferenceGrant
    listKind: ReferenceGrantList
    plural: referencegrants
    shortNames:
      - refgrant
    singular: referencegrant
  scope: Namespaced
  versions:
    - additionalPrinterColumns:
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
      deprecated: true
      deprecationWarning: The v1alpha2 version of ReferenceGrant has been deprecated and will be removed in a future release of the API. Please upgrade to v1beta1.
      name: v1alpha2
      schema:
        openAPIV3Schema:
          description: "ReferenceGrant identifies kinds of resources in other namespaces that are trusted to reference the specified kinds of resources in the same namespace as the policy. \n Each ReferenceGrant can be used to represent a unique trust relationship. Additional Reference Grants can be used to add to the set of trusted sources of inbound references for the namespace they are defined within. \n A ReferenceGrant is required for all cross-namespace references in Gateway API (with the exception of cross-namespace Route-Gateway attachment, which is governed by the AllowedRoutes configuration on the Gateway, and cross-namespace Service ParentRefs on a \"consumer\" mesh Route, which defines routing rules applicable only to workloads in the Route namespace). ReferenceGrants allowing a reference from a Route to a Service are only applicable to BackendRefs. \n ReferenceGrant is a form of runtime verification allowing users to assert which cross-namespace object references are permitted. Implementations that support ReferenceGrant MUST NOT permit cross-namespace references which have no grant, and MUST respond to the removal of a grant by revoking the access that the grant allowed."
          properties:
            apiVersion:
              description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
              type: string
            kind:
              description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
              type: string
            metadata:
              type: object
            spec:
              description: Spec defines the desired state of ReferenceGrant.
              properties:
                from:
                  description: "From describes the trusted namespaces and kinds that can reference the resources described in \"To\". Each entry in this list MUST be considered to be an additional place that references can be valid from, or to put this another way, entries MUST be combined using OR. \n Support: Core"
                  items:
                    description: ReferenceGrantFrom describes trusted namespaces and kinds.
                    properties:
                      group:
                        description: "Group is the group of the referent. When empty, the Kubernetes core API group is inferred. \n Support: Core"
                        maxLength: 253
                        pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      kind:
                        description: "Kind is the kind of the referent. Although implementations may support additional resources, the following types are part of the \"Core\" support level for this field. \n When used to permit a SecretObjectReference: \n * Gateway \n When used to permit a BackendObjectReference: \n * GRPCRoute * HTTPRoute * TCPRoute * TLSRoute * UDPRoute"
                        maxLength: 63
                        minLength: 1
                        pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                        type: string
                      namespace:
                        description: "Namespace is the namespace of the referent. \n Support: Core"
                        maxLength: 63
                        minLength: 1
                        pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
                        type: string
                    required:
                      - group
                      - kind
                      - namespace
                    type: object
                  maxItems: 16
                  minItems: 1
                  type: array
                to:
                  description: "To describes the resources that may be referenced by the resources described in \"From\". Each entry in this list MUST be considered to be an additional place that references can be valid to, or to put this another way, entries MUST be combined using OR. \n Support: Core"
                  items:
                    description: ReferenceGrantTo describes what Kinds are allowed as targets of the references.
                    properties:
                      group:
                        description: "Group is the group of the referent. When empty, the Kubernetes core API group is inferred. \n Support: Core"
                        maxLength: 253
                        pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      kind:
                        description: "Kind is the kind of the referent. Although implementations may support additional resources, the following types are part of the \"Core\" support level for this field: \n * Secret when used to permit a SecretObjectReference * Service when used to permit a BackendObjectReference"
                        maxLength: 63
                        minLength: 1
                        pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                        type: string
                      name:
                        description: Name is the name of the referent. When unspecified, this policy refers to all resources of the specified Group and Kind in the local namespace.
                        maxLength: 253
                        minLength: 1
                        type: string
                    required:
                      - group
                      - kind
                    type: object
                  maxItems: 16
                  minItems: 1
                  type: array
              required:
                - from
                - to
              type: object
          type: object
      served: true
      storage: false
      subresources: {}
    - additionalPrinterColumns:
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
      name: v1beta1
      schema:
        openAPIV3Schema:
          description: "ReferenceGrant identifies kinds of resources in other namespaces that are trusted to reference the specified kinds of resources in the same namespace as the policy. \n Each ReferenceGrant can be used to represent a unique trust relationship. Additional Reference Grants can be used to add to the set of trusted sources of inbound references for the namespace they are defined within. \n All cross-namespace references in Gateway API (with the exception of cross-namespace Gateway-route attachment) require a ReferenceGrant. \n ReferenceGrant is a form of runtime verification allowing users to assert which cross-namespace object references are permitted. Implementations that support ReferenceGrant MUST NOT permit cross-namespace references which have no grant, and MUST respond to the removal of a grant by revoking the access that the grant allowed."
          properties:
            apiVersion:
              description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
              type: string
            kind:
              description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
              type: string
            metadata:
              type: object
            spec:
              description: Spec defines the desired state of ReferenceGrant.
              properties:
                from:
                  description: "From describes the trusted namespaces and kinds that can reference the resources described in \"To\". Each entry in this list MUST be considered to be an additional place that references can be valid from, or to put this another way, entries MUST be combined using OR. \n Support: Core"
                  items:
                    description: ReferenceGrantFrom describes trusted namespaces and kinds.
                    properties:
                      group:
                        description: "Group is the group of the referent. When empty, the Kubernetes core API group is inferred. \n Support: Core"
                        maxLength: 253
                        pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      kind:
                        description: "Kind is the kind of the referent. Although implementations may support additional resources, the following types are part of the \"Core\" support level for this field. \n When used to permit a SecretObjectReference: \n * Gateway \n When used to permit a BackendObjectReference: \n * GRPCRoute * HTTPRoute * TCPRoute * TLSRoute * UDPRoute"
                        maxLength: 63
                        minLength: 1
                        pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                        type: string
                      namespace:
                        description: "Namespace is the namespace of the referent. \n Support: Core"
                        maxLength: 63
                        minLength: 1
                        pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
                        type: string
                    required:
                      - group
                      - kind
                      - namespace
                    type: object
                  maxItems: 16
                  minItems: 1
                  type: array
                to:
                  description: "To describes the resources that may be referenced by the resources described in \"From\". Each entry in this list MUST be considered to be an additional place that references can be valid to, or to put this another way, entries MUST be combined using OR. \n Support: Core"
                  items:
                    description: ReferenceGrantTo describes what Kinds are allowed as targets of the references.
                    properties:
                      group:
                        description: "Group is the group of the referent. When empty, the Kubernetes core API group is inferred. \n Support: Core"
                        maxLength: 253
                        pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      kind:
                        description: "Kind is the kind of the referent. Although implementations may support additional resources, the following types are part of the \"Core\" support level for this field: \n * Secret when used to permit a SecretObjectReference * Service when used to permit a BackendObjectReference"
                        maxLength: 63
                        minLength: 1
                        pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                        type: string
                      name:
                        description: Name is the name of the referent. When unspecified, this policy refers to all resources of the specified Group and Kind in the local namespace.
                        maxLength: 253
                        minLength: 1
                        type: string
                    required:
                      - group
                      - kind
                    type: object
                  maxItems: 16
                  minItems: 1
                  type: array
              required:
                - from
                - to
              type: object
          type: object
      served: true
      storage: true
      subresources: {}
