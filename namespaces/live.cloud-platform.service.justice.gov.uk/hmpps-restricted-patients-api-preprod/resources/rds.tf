variable "cluster_name" {
}


module "rp_rds" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-rds-instance?ref=5.16.11"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  namespace              = var.namespace
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support


  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "dps_rds" {
  metadata {
    name      = "rp-rds-instance-output"
    namespace = var.namespace
  }

  data = {
    rds_instance_endpoint = module.rp_rds.rds_instance_endpoint
    database_name         = module.rp_rds.database_name
    database_username     = module.rp_rds.database_username
    database_password     = module.rp_rds.database_password
    rds_instance_address  = module.rp_rds.rds_instance_address
    access_key_id         = module.rp_rds.access_key_id
    secret_access_key     = module.rp_rds.secret_access_key
    url                   = "postgres://${module.rp_rds.database_username}:${module.rp_rds.database_password}@${module.rp_rds.rds_instance_endpoint}/${module.rp_rds.database_name}"
  }
}

# This places a secret for this preprod RDS instance in the production namespace,
# this can then be used by a kubernetes job which will refresh the preprod data.
resource "kubernetes_secret" "dps_rds_refresh_creds" {
  metadata {
    name      = "rp-rds-instance-output-preprod"
    namespace = "hmpps-restricted-patients-api-prod"
  }

  data = {
    rds_instance_endpoint = module.rp_rds.rds_instance_endpoint
    database_name         = module.rp_rds.database_name
    database_username     = module.rp_rds.database_username
    database_password     = module.rp_rds.database_password
    rds_instance_address  = module.rp_rds.rds_instance_address
  }
}

