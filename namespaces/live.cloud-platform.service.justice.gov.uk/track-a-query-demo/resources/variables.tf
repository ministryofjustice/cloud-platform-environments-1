/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {
}


variable "namespace" {
  default = "track-a-query-demo"
}

variable "domain" {
  default = "demo.track-a-query.service.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "environment-name" {
  default = "demo"
}

