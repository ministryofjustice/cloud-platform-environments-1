# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
resource "kubernetes_role" "deploy" {
  metadata {
    namespace = var.namespace
    name      = "deploy"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["delete"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    verbs          = ["patch"]
    resource_names = ["app-versions"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["patch"]
    resource_names = [
      "deploy",
      "default",
      "api",
      "cashbook",
      "bank-admin",
      "noms-ops",
      "send-money",
      "start-page",
      "emails",
    ]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs"]
    verbs      = ["patch"]
    resource_names = [
      "transaction-uploader",
    ]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
    resource_names = [
      "irsa-deploy",
      "irsa-api",
      "irsa-cashbook",
      "irsa-bank-admin",
      "irsa-noms-ops",
      "irsa-send-money",
      "irsa-emails",
      "rds",
      "s3",
    ]
  }
}

resource "kubernetes_role_binding" "deploy" {
  metadata {
    namespace = var.namespace
    name      = "deploy"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.deploy.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = module.irsa-deploy.service_account.name
  }
}

resource "kubernetes_role" "api" {
  metadata {
    namespace = var.namespace
    name      = "api"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["get"]
    resource_names = ["s3"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "api" {
  metadata {
    namespace = var.namespace
    name      = "api"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.api.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = module.irsa-api.service_account.name
  }
}

resource "kubernetes_role" "cashbook" {
  metadata {
    namespace = var.namespace
    name      = "cashbook"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["get"]
    resource_names = ["s3"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "cashbook" {
  metadata {
    namespace = var.namespace
    name      = "cashbook"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cashbook.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = module.irsa-cashbook.service_account.name
  }
}

resource "kubernetes_role" "bank-admin" {
  metadata {
    namespace = var.namespace
    name      = "bank-admin"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["get"]
    resource_names = ["s3"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "bank-admin" {
  metadata {
    namespace = var.namespace
    name      = "bank-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.bank-admin.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = module.irsa-bank-admin.service_account.name
  }
}

resource "kubernetes_role" "noms-ops" {
  metadata {
    namespace = var.namespace
    name      = "noms-ops"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["get"]
    resource_names = ["s3"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "noms-ops" {
  metadata {
    namespace = var.namespace
    name      = "noms-ops"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.noms-ops.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = module.irsa-noms-ops.service_account.name
  }
}

resource "kubernetes_role" "send-money" {
  metadata {
    namespace = var.namespace
    name      = "send-money"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["get"]
    resource_names = ["s3"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "send-money" {
  metadata {
    namespace = var.namespace
    name      = "send-money"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.send-money.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = module.irsa-send-money.service_account.name
  }
}

resource "kubernetes_role" "emails" {
  metadata {
    namespace = var.namespace
    name      = "emails"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["get"]
    resource_names = ["s3"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "emails" {
  metadata {
    namespace = var.namespace
    name      = "emails"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.emails.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = module.irsa-emails.service_account.name
  }
}

module "service-account-circleci" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "circleci"
  role_name           = "circleci"
  rolebinding_name    = "circleci"

  serviceaccount_token_rotated_date = "05-02-2024"

  serviceaccount_rules = [
    {
      api_groups = [""],
      resources  = ["configmaps"],
      verbs      = ["get", "patch"],
    },
    {
      api_groups = ["extensions", "apps"],
      resources  = ["deployments"],
      verbs      = ["get", "patch"],
    },
    {
      api_groups = ["batch"],
      resources  = ["cronjobs"],
      verbs      = ["get", "patch"],
    },
    {
      api_groups = [""],
      resources  = ["pods"],
      verbs      = ["get", "list"],
    },
  ]
}

module "service-account-github-actions" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "github-actions"
  role_name           = "github-actions--basic"
  rolebinding_name    = "github-actions--basic"

  serviceaccount_token_rotated_date = "05-02-2024"

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources  = ["configmaps"]
      verbs      = ["get"]
    },
  ]
}

resource "kubernetes_role" "github-actions" {
  metadata {
    namespace = var.namespace
    name      = "github-actions"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments"]
    verbs      = ["get"]
  }

  rule {
    api_groups     = ["extensions", "apps"]
    resources      = ["deployments"]
    resource_names = ["default", "deploy"]
    verbs          = ["patch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "github-actions" {
  metadata {
    namespace = var.namespace
    name      = "github-actions"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "github-actions"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = "money-to-prisoners-test"
    name      = "github-actions"
  }
}
