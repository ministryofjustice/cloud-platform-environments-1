
# This module creates files to build docker image and 
# continuous deployment (CD) workflow in prototype github repo.

module "github-prototype" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-github-prototype?ref=0.1.1"

  namespace = var.namespace
}

module "github-prototype_branch" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-github-prototype?ref=branch-testing"

  namespace = var.namespace
  branch = "branch-testing"
  github_workflow_content          = trimspace("templates/cd-branch-testing.yaml")
  deployment_file_content          = trimspace("templates/kubernetes-deploy-branch-testing.tpl")
}