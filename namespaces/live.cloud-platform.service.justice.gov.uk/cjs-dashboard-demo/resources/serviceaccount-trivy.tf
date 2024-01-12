# Service account for trivy
module "trivy" {
    source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace                            = var.namespace
  kubernetes_cluster                   = var.kubernetes_cluster
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster

  serviceaccount_rules = [
     {
      api_groups = [
        "aquasecurity.github.io",
      ]
      resources = [
        "vulnerabilityreports",
      ]
      verbs = [
        "get",
        "list",
      ]
    },
  ]
}
