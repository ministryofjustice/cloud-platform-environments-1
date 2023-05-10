module "restricted_patients_queue_for_domain_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "rp_queue_for_domain_events"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.restricted_patients_queue_for_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "restricted_patients_queue_for_domain_events_queue_policy" {
  queue_url = module.restricted_patients_queue_for_domain_events.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.restricted_patients_queue_for_domain_events.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.restricted_patients_queue_for_domain_events.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.hmpps-domain-events.topic_arn}"
                          }
                        }
        }
      ]
  }
   EOF
}

module "restricted_patients_queue_for_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "rp_queue_for_domain_events_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "restricted_patients_queue_for_domain_events" {
  metadata {
    name      = "restricted-patients-queue-for-domain-events"
    namespace = "hmpps-restricted-patients-api-dev"
  }

  data = {
    access_key_id     = module.restricted_patients_queue_for_domain_events.access_key_id
    secret_access_key = module.restricted_patients_queue_for_domain_events.secret_access_key
    sqs_queue_url     = module.restricted_patients_queue_for_domain_events.sqs_id
    sqs_queue_arn     = module.restricted_patients_queue_for_domain_events.sqs_arn
    sqs_queue_name    = module.restricted_patients_queue_for_domain_events.sqs_name
    irsa_policy_arn   = module.restricted_patients_queue_for_domain_events.irsa_policy_arn
  }
}

resource "kubernetes_secret" "restricted_patients_queue_for_domain_events_dead_letter_queue" {
  metadata {
    name      = "restricted-patients-dlq-for-domain-events"
    namespace = "hmpps-restricted-patients-api-dev"
  }

  data = {
    access_key_id     = module.restricted_patients_queue_for_domain_events_dead_letter_queue.access_key_id
    secret_access_key = module.restricted_patients_queue_for_domain_events_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.restricted_patients_queue_for_domain_events_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.restricted_patients_queue_for_domain_events_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.restricted_patients_queue_for_domain_events_dead_letter_queue.sqs_name
    irsa_policy_arn   = module.restricted_patients_queue_for_domain_events_dead_letter_queue.irsa_policy_arn
  }
}

resource "aws_ssm_parameter" "hmpps-restricted-patients-sqs" {
  type = "String"
  name = "/${var.namespace}/hmpps-restricted-patients-sqs"
  value = jsonencode({
    "irsa_policy_arn" : module.restricted_patients_queue_for_domain_events.irsa_policy_arn
    "irsa_policy_arn_dql" : module.restricted_patients_queue_for_domain_events_dead_letter_queue.irsa_policy_arn
  })
  description = "Output from hmpps-restricted-patients sqs modules; use these parameters in other DPS dev namespaces"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_sns_topic_subscription" "restricted_patients_queue_for_domain_events_subscription_details" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.restricted_patients_queue_for_domain_events.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.merged\"]}"
}
