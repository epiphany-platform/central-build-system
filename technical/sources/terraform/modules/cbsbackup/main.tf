resource "kubernetes_namespace" "cbsbackup_ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "backup_cbs" {
  metadata {
    name      = "cbsbackup"
    namespace = var.namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "cbsbackup" {
  metadata {
    name       = "cbsbackup"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["dashboard.tekton.dev"]
    resources  = ["extensions"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["tekton.dev"]
    resources  = ["clustertasks", "conditions", "pipelineresources", "pipelines", "tasks"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["triggers.tekton.dev"]
    resources  = ["triggerbindings", "triggers", "triggertemplates", "eventlisteners", "clustertriggerbindings"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
}

resource "kubernetes_cluster_role_binding" "cbsrolebinding" {
  metadata {
    name      = "cbsrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cbsbackup"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cbsbackup"
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "sastoken" {
  metadata {
    name      = "sas-token"
    namespace = var.namespace
  }
  data = {
    SAS = var.sas_token
  }
}

resource "kubernetes_cron_job" "backup_job" {
  metadata {
    name      = "backup-job"
    namespace = var.namespace
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    successful_jobs_history_limit = 5
    schedule                      = "0 4 * * *"
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            service_account_name            = "cbsbackup"
            automount_service_account_token = true
            container {
              name              = "backupjob"
              image             = "harbor.${var.domain}/public/cbsbackup:0.0.6"
              image_pull_policy = "IfNotPresent"
              env {
                name  = "HARBOR_NS"
                value = var.harbor_namespace
              }
              env {
                name  = "ARGO_NS"
                value = var.argocd_namespace
              }
              env {
                name  = "STORAGE"
                value = var.storage_name
              }
              env {
                name  = "CONTAINER"
                value = var.container_name
              }
              env_from {
                secret_ref {
                  name = "sas-token"
                }
              }
            }
          }
        }
      }
    }
  }
}
