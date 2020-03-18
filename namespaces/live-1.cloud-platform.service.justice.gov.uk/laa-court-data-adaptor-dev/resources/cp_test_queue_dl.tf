module "cp_test_queue_dl" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = "development"
  team_name                 = "crimeapps"
  application               = "crimeapps"
  sqs_name                  = "cp-test-queue-dl"
  infrastructure-support    = "example-team@digtal.justice.gov.uk"
  encrypt_sqs_kms           = "false"
  message_retention_seconds = 1209600


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "cp_test_queue_dl" {
  queue_url = module.cp_test_queue_dl.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cp_test_queue_dl.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "first",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cp_test_queue_dl.sqs_arn}",
          "Action": "SQS:*"
        },
        {
          "Sid": "Second",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "902837325998"
              ]
          },
          "Action": "sqs:ReceiveMessage",
          "Resource": "arn:aws:sqs:eu-west-2:754256621582:crimeapps-development-cp-test-queue-dl"
        }
      ]
  }
   EOF
}

resource "kubernetes_secret" "cp_test_queue_dl" {
  metadata {
    name      = "cp-test-queue-dl-instance-output"
    namespace = "laa-court-data-adaptor-dev"
  }

  data = {
    access_key_id     = module.cp_test_queue_dl.access_key_id
    secret_access_key = module.cp_test_queue_dl.secret_access_key
    sqs_id            = module.cp_test_queue_dl.sqs_id
    sqs_arn           = module.cp_test_queue_dl.sqs_arn
    sqs_name          = module.cp_test_queue_dl.sqs_name
  }
}
