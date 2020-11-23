variable "rg_name" {
  type        = string
  description = "Existing resource group name"
}

variable "location" {
  type = string
  default = "West Europe"
}

variable "project_name" {
  type = string
  default = "cbs-harbor"
}

variable "namespace" {
  default = "harbor"
  type = string
}

variable "tls_secret_name" {
  default = ""
  type = string
}

variable "url" {
  default = "core.harbor.domain"
  type = string
}