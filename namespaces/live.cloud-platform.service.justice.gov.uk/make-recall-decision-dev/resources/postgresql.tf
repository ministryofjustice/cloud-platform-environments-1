##
## PostgreSQL - Application Database
##

module "make_recall_decision_api_rds" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.18.0"
  enable_rds_auto_start_stop = true
  vpc_name               = var.vpc_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name

  rds_name          = "make-recall-decision-${var.environment}"
  rds_family        = "postgres13"
  db_engine         = "postgres"
  db_engine_version = "13"
  db_instance_class = "db.t3.small"
  db_name           = "make_recall_decision"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "make_recall_decision_api_rds" {
  metadata {
    name      = "make-recall-decision-api-database"
    namespace = var.namespace
  }

  data = {
    host     = module.make_recall_decision_api_rds.rds_instance_address
    name     = module.make_recall_decision_api_rds.database_name
    username = module.make_recall_decision_api_rds.database_username
    password = module.make_recall_decision_api_rds.database_password
  }
}


