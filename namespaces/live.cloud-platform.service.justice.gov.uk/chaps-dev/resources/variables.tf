variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "correspondence handling and processing system"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "namespace" {
  default = "chaps-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HQ"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "dotnet"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "chaps-support@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "chaps"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_TOKEN_DEV"
}

variable "github_actions_secret_ecr_name" {
  description = "The name of the github actions secret containing the ECR name"
  default     = "ECR_NAME_DEV"
}

variable "github_actions_secret_ecr_url" {
  description = "The name of the github actions secret containing the ECR URL"
  default     = "ECR_URL_DEV"
}

variable "github_actions_secret_ecr_access_key" {
  description = "The name of the github actions secret containing the ECR AWS access key"
  default     = "ECR_AWS_ACCESS_KEY_ID_DEV"
}

variable "github_actions_secret_ecr_secret_key" {
  description = "The name of the github actions secret containing the ECR AWS secret key"
  default     = "ECR_AWS_SECRET_ACCESS_KEY_DEV"
}

variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the kubernetes cluster name"
  default     = "KUBE_CLUSTER_DEV"
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_NAMESPACE_DEV"
}

variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_CERT_DEV"
}

variable "serviceaccount_rules" {
  description = "The capabilities of this serviceaccount"

  type = list(object({
    api_groups = list(string),
    resources  = list(string),
    verbs      = list(string)
  }))

  # These values are usually sufficient for a CI/CD pipeline
  default = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods",
        "certificates"
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "delete",
        "list",
        "watch",
        "update",
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "networking.k8s.io",
        "cert-manager.io"
      ]
      resources = [
        "deployments",
        "ingresses",
        "certificates"
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
        "list",
        "watch",
      ]
    },
  ]
}
