variable "domain" {
  default = "claim-crown-court-defence.service.justice.gov.uk"
}

variable "application" {
  default = "cccd"
}

variable "namespace" {
  default = "cccd-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "legal-aid-agency"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-get-paid"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "crowncourtdefence@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */

variable "vpc_name" {
}


