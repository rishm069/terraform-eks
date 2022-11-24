variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "ecr_repository_name" {
  description = "Namespace for dummy app"
  type        = string
  default     = "dummy-app"
}
