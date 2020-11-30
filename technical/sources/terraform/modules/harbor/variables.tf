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

variable "tls_secret_name" {
  type    = string
  default = ""
}

variable "url" {
  type    = string
  default = "core.harbor.domain"
}
