variable "rg_name" {
  type        = string
  description = "Existing resource group name"
}

variable "storage_account_name" {
  type        = string
  description = "Unique name across Azure for storage account"
}

variable "location" {
  type    = string
  default = "West Europe"
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
