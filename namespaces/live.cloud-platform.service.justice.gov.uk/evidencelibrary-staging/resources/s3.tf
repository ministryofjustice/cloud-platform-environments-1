module "evidencelibrary_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.0.0"
  acl                    = "private"
  versioning             = true
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

resource "kubernetes_secret" "evidencelibrary_document_s3_bucket" {
  metadata {
    name      = "evidencelibrary-document-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.evidencelibrary_document_s3_bucket.bucket_arn
    bucket_name = module.evidencelibrary_document_s3_bucket.bucket_name
  }
}
