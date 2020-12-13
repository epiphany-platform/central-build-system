variable project_name {
  type = string
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

variable "max_aks_nodes_number" {
  type = number
  default = 2
}

variable "argocd_ns" {
  default = "argocd"
}

variable "peering" {
  type    = bool
  default = true
}

variable "harbor_prefix" {
  type    = string
  default = "harbor"  
}

variable "notary_prefix" {
  type    = string
  default = "notary"  
}
