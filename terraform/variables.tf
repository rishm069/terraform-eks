variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "ecr_repository_name" {
  type        = string
  default     = "dummy-app"
}
