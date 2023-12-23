# Copyright 2023 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Gateway API Experimental channel install
#
#
# config/crd/experimental/gateway.networking.k8s.io_backendtlspolicies.yaml
#
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    api-approved.kubernetes.io: https://github.com/kubernetes-sigs/gateway-api/pull/2466
    gateway.networking.k8s.io/bundle-version: v1.0.0
    gateway.networking.k8s.io/channel: experimental
  labels:
    gateway.networking.k8s.io/policy: Direct
  name: backendtlspolicies.gateway.networking.k8s.io
spec:
  group: gateway.networking.k8s.io
  names:
    categories:
      - gateway-api
    kind: BackendTLSPolicy
    listKind: BackendTLSPolicyList
    plural: backendtlspolicies
    shortNames:
      - btlspolicy
    singular: backendtlspolicy
  scope: Namespaced
  versions:
    - additionalPrinterColumns:
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
      name: v1alpha2
      schema:
        openAPIV3Schema:
          description: BackendTLSPolicy provides a way to configure how a Gateway connects to a Backend via TLS.
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
              description: Spec defines the desired state of BackendTLSPolicy.
              properties:
                targetRef:
                  description: "TargetRef identifies an API object to apply the policy to. Only Services have Extended support. Implementations MAY support additional objects, with Implementation Specific support. Note that this config applies to the entire referenced resource by default, but this default may change in the future to provide a more granular application of the policy. \n Support: Extended for Kubernetes Service \n Support: Implementation-specific for any other resource"
                  properties:
                    group:
                      description: Group is the group of the target resource.
                      maxLength: 253
                      pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                      type: string
                    kind:
                      description: Kind is kind of the target resource.
                      maxLength: 63
                      minLength: 1
                      pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                      type: string
                    name:
                      description: Name is the name of the target resource.
                      maxLength: 253
                      minLength: 1
                      type: string
                    namespace:
                      description: Namespace is the namespace of the referent. When unspecified, the local namespace is inferred. Even when policy targets a resource in a different namespace, it MUST only apply to traffic originating from the same namespace as the policy.
                      maxLength: 63
                      minLength: 1
                      pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
                      type: string
                    sectionName:
                      description: "SectionName is the name of a section within the target resource. When unspecified, this targetRef targets the entire resource. In the following resources, SectionName is interpreted as the following: \n * Gateway: Listener Name * Service: Port Name \n If a SectionName is specified, but does not exist on the targeted object, the Policy must fail to attach, and the policy implementation should record a `ResolvedRefs` or similar Condition in the Policy's status."
                      maxLength: 253
                      minLength: 1
                      pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                      type: string
                  required:
                    - group
                    - kind
                    - name
                  type: object
                tls:
                  description: TLS contains backend TLS policy configuration.
                  properties:
                    caCertRefs:
                      description: "CACertRefs contains one or more references to Kubernetes objects that contain a PEM-encoded TLS CA certificate bundle, which is used to validate a TLS handshake between the Gateway and backend Pod. \n If CACertRefs is empty or unspecified, then WellKnownCACerts must be specified. Only one of CACertRefs or WellKnownCACerts may be specified, not both. If CACertRefs is empty or unspecified, the configuration for WellKnownCACerts MUST be honored instead. \n References to a resource in a different namespace are invalid for the moment, although we will revisit this in the future. \n A single CACertRef to a Kubernetes ConfigMap kind has \"Core\" support. Implementations MAY choose to support attaching multiple certificates to a backend, but this behavior is implementation-specific. \n Support: Core - An optional single reference to a Kubernetes ConfigMap, with the CA certificate in a key named `ca.crt`. \n Support: Implementation-specific (More than one reference, or other kinds of resources)."
                      items:
                        description: "LocalObjectReference identifies an API object within the namespace of the referrer. The API object must be valid in the cluster; the Group and Kind must be registered in the cluster for this reference to be valid. \n References to objects with invalid Group and Kind are not valid, and must be rejected by the implementation, with appropriate Conditions set on the containing object."
                        properties:
                          group:
                            description: Group is the group of the referent. For example, "gateway.networking.k8s.io". When unspecified or empty string, core API group is inferred.
                            maxLength: 253
                            pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                            type: string
                          kind:
                            description: Kind is kind of the referent. For example "HTTPRoute" or "Service".
                            maxLength: 63
                            minLength: 1
                            pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                            type: string
                          name:
                            description: Name is the name of the referent.
                            maxLength: 253
                            minLength: 1
                            type: string
                        required:
                          - group
                          - kind
                          - name
                        type: object
                      maxItems: 8
                      type: array
                    hostname:
                      description: "Hostname is used for two purposes in the connection between Gateways and backends: \n 1. Hostname MUST be used as the SNI to connect to the backend (RFC 6066). 2. Hostname MUST be used for authentication and MUST match the certificate served by the matching backend. \n Support: Core"
                      maxLength: 253
                      minLength: 1
                      pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                      type: string
                    wellKnownCACerts:
                      description: "WellKnownCACerts specifies whether system CA certificates may be used in the TLS handshake between the gateway and backend pod. \n If WellKnownCACerts is unspecified or empty (\"\"), then CACertRefs must be specified with at least one entry for a valid configuration. Only one of CACertRefs or WellKnownCACerts may be specified, not both. \n Support: Core for \"System\""
                      enum:
                        - System
                      type: string
                  required:
                    - hostname
                  type: object
                  x-kubernetes-validations:
                    - message: must not contain both CACertRefs and WellKnownCACerts
                      rule: '!(has(self.caCertRefs) && size(self.caCertRefs) > 0 && has(self.wellKnownCACerts) && self.wellKnownCACerts != "")'
                    - message: must specify either CACertRefs or WellKnownCACerts
                      rule: (has(self.caCertRefs) && size(self.caCertRefs) > 0 || has(self.wellKnownCACerts) && self.wellKnownCACerts != "")
              required:
                - targetRef
                - tls
              type: object
            status:
              description: Status defines the current state of BackendTLSPolicy.
              properties:
                ancestors:
                  description: "Ancestors is a list of ancestor resources (usually Gateways) that are associated with the policy, and the status of the policy with respect to each ancestor. When this policy attaches to a parent, the controller that manages the parent and the ancestors MUST add an entry to this list when the controller first sees the policy and SHOULD update the entry as appropriate when the relevant ancestor is modified. \n Note that choosing the relevant ancestor is left to the Policy designers; an important part of Policy design is designing the right object level at which to namespace this status. \n Note also that implementations MUST ONLY populate ancestor status for the Ancestor resources they are responsible for. Implementations MUST use the ControllerName field to uniquely identify the entries in this list that they are responsible for. \n Note that to achieve this, the list of PolicyAncestorStatus structs MUST be treated as a map with a composite key, made up of the AncestorRef and ControllerName fields combined. \n A maximum of 16 ancestors will be represented in this list. An empty list means the Policy is not relevant for any ancestors. \n If this slice is full, implementations MUST NOT add further entries. Instead they MUST consider the policy unimplementable and signal that on any related resources such as the ancestor that would be referenced here. For example, if this list was full on BackendTLSPolicy, no additional Gateways would be able to reference the Service targeted by the BackendTLSPolicy."
                  items:
                    description: "PolicyAncestorStatus describes the status of a route with respect to an associated Ancestor. \n Ancestors refer to objects that are either the Target of a policy or above it in terms of object hierarchy. For example, if a policy targets a Service, the Policy's Ancestors are, in order, the Service, the HTTPRoute, the Gateway, and the GatewayClass. Almost always, in this hierarchy, the Gateway will be the most useful object to place Policy status on, so we recommend that implementations SHOULD use Gateway as the PolicyAncestorStatus object unless the designers have a _very_ good reason otherwise. \n In the context of policy attachment, the Ancestor is used to distinguish which resource results in a distinct application of this policy. For example, if a policy targets a Service, it may have a distinct result per attached Gateway. \n Policies targeting the same resource may have different effects depending on the ancestors of those resources. For example, different Gateways targeting the same Service may have different capabilities, especially if they have different underlying implementations. \n For example, in BackendTLSPolicy, the Policy attaches to a Service that is used as a backend in a HTTPRoute that is itself attached to a Gateway. In this case, the relevant object for status is the Gateway, and that is the ancestor object referred to in this status. \n Note that a parent is also an ancestor, so for objects where the parent is the relevant object for status, this struct SHOULD still be used. \n This struct is intended to be used in a slice that's effectively a map, with a composite key made up of the AncestorRef and the ControllerName."
                    properties:
                      ancestorRef:
                        description: AncestorRef corresponds with a ParentRef in the spec that this PolicyAncestorStatus struct describes the status of.
                        properties:
                          group:
                            default: gateway.networking.k8s.io
                            description: "Group is the group of the referent. When unspecified, \"gateway.networking.k8s.io\" is inferred. To set the core API group (such as for a \"Service\" kind referent), Group must be explicitly set to \"\" (empty string). \n Support: Core"
                            maxLength: 253
                            pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                            type: string
                          kind:
                            default: Gateway
                            description: "Kind is kind of the referent. \n There are two kinds of parent resources with \"Core\" support: \n * Gateway (Gateway conformance profile) * Service (Mesh conformance profile, experimental, ClusterIP Services only) \n Support for other resources is Implementation-Specific."
                            maxLength: 63
                            minLength: 1
                            pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                            type: string
                          name:
                            description: "Name is the name of the referent. \n Support: Core"
                            maxLength: 253
                            minLength: 1
                            type: string
                          namespace:
                            description: "Namespace is the namespace of the referent. When unspecified, this refers to the local namespace of the Route. \n Note that there are specific rules for ParentRefs which cross namespace boundaries. Cross-namespace references are only valid if they are explicitly allowed by something in the namespace they are referring to. For example: Gateway has the AllowedRoutes field, and ReferenceGrant provides a generic way to enable any other kind of cross-namespace reference. \n  ParentRefs from a Route to a Service in the same namespace are \"producer\" routes, which apply default routing rules to inbound connections from any namespace to the Service. \n ParentRefs from a Route to a Service in a different namespace are \"consumer\" routes, and these routing rules are only applied to outbound connections originating from the same namespace as the Route, for which the intended destination of the connections are a Service targeted as a ParentRef of the Route.  \n Support: Core"
                            maxLength: 63
                            minLength: 1
                            pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
                            type: string
                          port:
                            description: "Port is the network port this Route targets. It can be interpreted differently based on the type of parent resource. \n When the parent resource is a Gateway, this targets all listeners listening on the specified port that also support this kind of Route(and select this Route). It's not recommended to set `Port` unless the networking behaviors specified in a Route must apply to a specific port as opposed to a listener(s) whose port(s) may be changed. When both Port and SectionName are specified, the name and port of the selected listener must match both specified values. \n  When the parent resource is a Service, this targets a specific port in the Service spec. When both Port (experimental) and SectionName are specified, the name and port of the selected port must match both specified values.  \n Implementations MAY choose to support other parent resources. Implementations supporting other types of parent resources MUST clearly document how/if Port is interpreted. \n For the purpose of status, an attachment is considered successful as long as the parent resource accepts it partially. For example, Gateway listeners can restrict which Routes can attach to them by Route kind, namespace, or hostname. If 1 of 2 Gateway listeners accept attachment from the referencing Route, the Route MUST be considered successfully attached. If no Gateway listeners accept attachment from this Route, the Route MUST be considered detached from the Gateway. \n Support: Extended \n "
                            format: int32
                            maximum: 65535
                            minimum: 1
                            type: integer
                          sectionName:
                            description: "SectionName is the name of a section within the target resource. In the following resources, SectionName is interpreted as the following: \n * Gateway: Listener Name. When both Port (experimental) and SectionName are specified, the name and port of the selected listener must match both specified values. * Service: Port Name. When both Port (experimental) and SectionName are specified, the name and port of the selected listener must match both specified values. Note that attaching Routes to Services as Parents is part of experimental Mesh support and is not supported for any other purpose. \n Implementations MAY choose to support attaching Routes to other resources. If that is the case, they MUST clearly document how SectionName is interpreted. \n When unspecified (empty string), this will reference the entire resource. For the purpose of status, an attachment is considered successful if at least one section in the parent resource accepts it. For example, Gateway listeners can restrict which Routes can attach to them by Route kind, namespace, or hostname. If 1 of 2 Gateway listeners accept attachment from the referencing Route, the Route MUST be considered successfully attached. If no Gateway listeners accept attachment from this Route, the Route MUST be considered detached from the Gateway. \n Support: Core"
                            maxLength: 253
                            minLength: 1
                            pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                            type: string
                        required:
                          - name
                        type: object
                      conditions:
                        description: Conditions describes the status of the Policy with respect to the given Ancestor.
                        items:
                          description: "Condition contains details for one aspect of the current state of this API Resource. --- This struct is intended for direct use as an array at the field path .status.conditions.  For example, \n type FooStatus struct{ // Represents the observations of a foo's current state. // Known .status.conditions.type are: \"Available\", \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge // +listType=map // +listMapKey=type Conditions []metav1.Condition `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\" protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                          properties:
                            lastTransitionTime:
                              description: lastTransitionTime is the last time the condition transitioned from one status to another. This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                              format: date-time
                              type: string
                            message:
                              description: message is a human readable message indicating details about the transition. This may be an empty string.
                              maxLength: 32768
                              type: string
                            observedGeneration:
                              description: observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance.
                              format: int64
                              minimum: 0
                              type: integer
                            reason:
                              description: reason contains a programmatic identifier indicating the reason for the condition's last transition. Producers of specific condition types may define expected values and meanings for this field, and whether the values are considered a guaranteed API. The value should be a CamelCase string. This field may not be empty.
                              maxLength: 1024
                              minLength: 1
                              pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                              type: string
                            status:
                              description: status of the condition, one of True, False, Unknown.
                              enum:
                                - "True"
                                - "False"
                                - Unknown
                              type: string
                            type:
                              description: type of condition in CamelCase or in foo.example.com/CamelCase. --- Many .condition.type values are consistent across resources like Available, but because arbitrary conditions can be useful (see .node.status.conditions), the ability to deconflict is important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                              maxLength: 316
                              pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                              type: string
                          required:
                            - lastTransitionTime
                            - message
                            - reason
                            - status
                            - type
                          type: object
                        maxItems: 8
                        minItems: 1
                        type: array
                        x-kubernetes-list-map-keys:
                          - type
                        x-kubernetes-list-type: map
                      controllerName:
                        description: "ControllerName is a domain/path string that indicates the name of the controller that wrote this status. This corresponds with the controllerName field on GatewayClass. \n Example: \"example.net/gateway-controller\". \n The format of this field is DOMAIN \"/\" PATH, where DOMAIN and PATH are valid Kubernetes names (https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names). \n Controllers MUST populate this field when writing status. Controllers should ensure that entries to status populated with their ControllerName are cleaned up when they are no longer necessary."
                        maxLength: 253
                        minLength: 1
                        pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]+$
                        type: string
                    required:
                      - ancestorRef
                      - controllerName
                    type: object
                  maxItems: 16
                  type: array
              required:
                - ancestors
              type: object
          required:
            - spec
          type: object
      served: true
      storage: true
      subresources:
        status: {}
