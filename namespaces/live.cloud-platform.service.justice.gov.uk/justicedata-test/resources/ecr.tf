module "ecr" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=6.0.0"

  repo_name              = "${var.namespace}-ecr"

  oidc_providers         = ["github"]
  github_repositories    = ["justice-data"]
  github_actions_prefix  = "test"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
