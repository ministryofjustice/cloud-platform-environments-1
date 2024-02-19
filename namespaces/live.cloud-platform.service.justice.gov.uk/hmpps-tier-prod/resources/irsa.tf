locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-hmpps_tier_offender_events_queue"    = "offender-events-prod"
    "Digital-Prison-Services-prod-hmpps_tier_offender_events_queue_dl" = "offender-events-prod"
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = var.application
  namespace            = var.namespace
  role_policy_arns = merge(
    local.sns_policies,
    local.sqs_policies,
    { domain_sns = module.hmpps_tier_domain_events_queue.irsa_policy_arn },
    { domain_dlq = module.hmpps_tier_domain_events_dead_letter_queue.irsa_policy_arn },
    { audit_sqs = data.kubernetes_secret.audit_secret.data.irsa_policy_arn },
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}