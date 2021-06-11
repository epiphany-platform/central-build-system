variable "kube_host" {}

variable "kube_cluster_ca" {}

variable "kube_client_key" {}

variable "kube_client_cert" {}

variable "storage_account_name" {
  type        = string
  description = "Unique name across Azure for storage account"
}

variable "storage_primary_access_key" {
  type        = string
  description = "Primary access key for storage account"
}

variable "storage_container_name" {
  type        = string
  description = "Container for harbor blobs"
}

variable "project_name" {
  type    = string
  default = "cbs-harbor"
}

variable "namespace" {
  type    = string
  default = "harbor"
}

variable "harbor_tls_secret_name" {
  type    = string
  default = "harbor-tls"
}

variable "notary_tls_secret_name" {
  type    = string
  default = "notary-tls"
}

variable "harbor_url" {
  type    = string
  default = "core.harbor.domain"
}

variable "notary_url" {
  type    = string
  default = "notary.harbor.domain"
}

variable "harbor_version" {
  type    = string
  default = "1.6.2"
}
