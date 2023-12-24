variable "namespace" {
  description = "namespace where to install resources"
}

variable "storage_class" {
  description = "storage class name to use for workload PVCs"
  default     = "gp"
}
