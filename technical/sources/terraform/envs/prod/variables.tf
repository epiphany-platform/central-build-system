variable project_name {
  type = string
}

variable location {
  type = string
}

variable "address_space" {
  type = list
}

variable "address_prefixes" {
  type = list
}

variable "key_path" {
  default = "shared/.pub"
}

variable "no_vms" {
  default = 0
}

variable "use_public_ips" {
  default = false
  type    = bool
}
variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "aad_admin_groups" {
  type        = list
  description = "Pass empty if no integration needed"
}

variable "argocd_ns" {
  default = "argocd"
}

variable "vm_rg_name" {
  type = string
}

variable "vm_vnet_name" {
  type = string
}

variable "vm_vnet_id" {
  type = string
}

variable "peering" {
  type    = bool
  default = true
}

variable "argo_prefix" {}

variable "tekton_prefix" {}

variable "domain" {}

variable "tekton_operator_container" {}

variable "harbor_prefix" {}

variable "harbor_tls_secret_name" {
  type        = string
  description = "Kubernetes secret name which stores TLS certificate for domain"
}

variable "harbor_storage_account_name" {
  type        = string
  description = "Unique name across Azure for storage account"
}
