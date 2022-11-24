variable "namespace_name" {
  type = string
  default = "dummy-app"
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_certificate_authority_data" {
  type = string
}

variable "cluster_name" {
  type = string
}
