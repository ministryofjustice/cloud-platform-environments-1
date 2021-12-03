# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
variable "cluster_name" {}

module "rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.7"

  providers = {
    aws = aws.london
  }

  cluster_name = var.cluster_name

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.email

  rds_family           = "postgres10"
  db_engine            = "postgres"
  db_engine_version    = "10"
  db_instance_class    = "db.m5.large"
  db_allocated_storage = "50"
  db_name              = "mtp_api"

  allow_major_version_upgrade = false
  deletion_protection         = true
}

resource "kubernetes_secret" "rds" {
  metadata {
    name      = "rds"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rds.rds_instance_endpoint
    database_name         = module.rds.database_name
    database_username     = module.rds.database_username
    database_password     = module.rds.database_password
    rds_instance_address  = module.rds.rds_instance_address
    rds_instance_port     = module.rds.rds_instance_port
    access_key_id         = module.rds.access_key_id
    secret_access_key     = module.rds.secret_access_key
  }
}
