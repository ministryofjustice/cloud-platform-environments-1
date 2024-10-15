module "ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.1.1"
  team_name = var.team_name
  repo_name = "${var.namespace}-live-2-ecr"
  github_repositories = ["my-repo"]
}
