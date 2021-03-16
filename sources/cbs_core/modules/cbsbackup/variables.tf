variable "kubeconfig" {}

variable "kube_host" {}

variable "kube_cluster_ca" {}

variable "kube_client_key" {}

variable "kube_client_cert" {}

variable "namespace" {
  type    = string
  default = "cbsbackup"
}

variable "harbor_namespace" {
  type    = string
}

variable "argocd_namespace" {
  type    = string
}

variable "sas_token" {
  type    = string
}

variable "storage_name" {
  type    = string
}

variable "container_name" {
  type    = string
}

variable "domain" {
  type   = string
}
