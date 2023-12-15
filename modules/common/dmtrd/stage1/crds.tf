resource "kubernetes_manifest" "crd_dependencies" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind"       = "CustomResourceDefinition"
    "metadata" = {
      "name" = "dependencies.demeter.run"
    }
    "spec" = {
      "group" = "demeter.run"
      "names" = {
        "kind"   = "Dependency"
        "plural" = "dependencies"
        "shortNames" = [
          "dps",
        ]
        "singular" = "dependency"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "name" = "v1alpha1"
          "schema" = {
            "openAPIV3Schema" = {
              "properties" = {
                "spec" = {
                  "properties" = {
                    "serviceId" = {
                      "type" = "string"
                    }
                    "serviceKind" = {
                      "type" = "string"
                    }
                    "instanceId" = {
                      "type" = "string"
                    }
                    "instanceName" = {
                      "type" = "string"
                    }
                    "instanceSalt" = {
                      "type" = "string"
                    }
                    "serviceVersion" = {
                      "type" = "string"
                    }
                    "annotations" = {
                      "type" = "object"
                      "x-kubernetes-preserve-unknown-fields" = true
                    }
                  }
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "additionalPrinterColumns": [
            {
              "name": "Service Kind"
              "type": "string"
              "jsonPath": ".spec.serviceKind"
            },
            {
              "name": "Service Instance"
              "type": "string"
              "jsonPath": ".spec.instanceId"
            },
            {
              "name": "Instance Name"
              "type": "string"
              "jsonPath": ".spec.instanceName"
            },
            {
              "name": "Service Salt"
              "type": "string"
              "jsonPath": ".spec.instanceSalt"
            }
          ]
            
          
          "served"  = true
          "storage" = true
        },
      ]
    }
  }
}
