data "aws_caller_identity" "current" {}

module "ecr" {
  source  = "cloudposse/ecr/aws"
  version = "0.34.0"

  name                   = var.ecr_repository_name
  use_fullname           = false
  max_image_count        = 30
  principals_full_access = [data.aws_caller_identity.current.arn]
}
