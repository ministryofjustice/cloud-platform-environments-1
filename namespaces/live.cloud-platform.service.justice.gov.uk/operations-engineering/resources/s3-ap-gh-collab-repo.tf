module "ap_gh_collab_repo_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.9.0"
  acl    = "private"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ap_gh_collab_repo_s3_bucket" {
  metadata {
    name      = "tfstate-s3-bucket-ap-gh-collab-repo"
    namespace = var.namespace
  }

  data = {
    bucket_arn = module.ap_gh_collab_repo_s3_bucket.bucket_arn
  }
}
