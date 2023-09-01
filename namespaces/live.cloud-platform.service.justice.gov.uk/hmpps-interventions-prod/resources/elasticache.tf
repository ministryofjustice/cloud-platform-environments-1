module "hmpps_interventions_elasticache_redis" {
  source                  = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.3.0"
  vpc_name                = var.vpc_name
  application             = var.application
  environment_name        = var.environment
  is_production           = var.is_production
  infrastructure_support  = var.infrastructure_support
  team_name               = var.team_name
  business_unit           = var.business_unit
  number_cache_clusters   = var.number_cache_clusters
  node_type               = "cache.t4g.small"
  engine_version          = "7.0"
  parameter_group_name    = "default.redis7"
  namespace               = var.namespace
  auth_token_rotated_date = "2023-08-04"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_interventions_elasticache_redis" {
  metadata {
    name      = "elasticache-redis"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.hmpps_interventions_elasticache_redis.primary_endpoint_address
    auth_token               = module.hmpps_interventions_elasticache_redis.auth_token
    member_clusters          = jsonencode(module.hmpps_interventions_elasticache_redis.member_clusters)
  }
}
