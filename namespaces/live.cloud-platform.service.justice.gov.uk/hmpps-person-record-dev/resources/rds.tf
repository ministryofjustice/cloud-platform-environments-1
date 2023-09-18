module "hmpps_person_record_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.20.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  rds_family             = "postgres14"
  db_instance_class      = "db.t3.small"
  db_engine              = "postgres"
  db_engine_version      = "14"

  allow_major_version_upgrade = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_person_record_rds" {
  metadata {
    name      = "hmpps-person-record-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.hmpps_person_record_rds.rds_instance_endpoint
    database_name         = module.hmpps_person_record_rds.database_name
    database_username     = module.hmpps_person_record_rds.database_username
    database_password     = module.hmpps_person_record_rds.database_password
    rds_instance_address  = module.hmpps_person_record_rds.rds_instance_address
    access_key_id         = module.hmpps_person_record_rds.access_key_id
    secret_access_key     = module.hmpps_person_record_rds.secret_access_key
    url                   = "postgres://${module.hmpps_person_record_rds.database_username}:${module.hmpps_person_record_rds.database_password}@${module.hmpps_person_record_rds.rds_instance_endpoint}/${module.hmpps_person_record_rds.database_name}"
  }
}
