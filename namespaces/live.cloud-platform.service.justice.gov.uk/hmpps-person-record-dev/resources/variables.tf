variable "vpc_name" {
}

variable "application" {
  default = "person-record-service"
}

variable "namespace" {
  default = "hmpps-person-record-dev"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "hmpps-developers"
}

variable "environment" {
  default = "development"
}

variable "environment-name" {
  default = "development"
}

variable "infrastructure_support" {
  default = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}


variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

variable "eks_cluster_name" {
}
