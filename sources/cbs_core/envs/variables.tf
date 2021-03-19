### BASIC VARS
variable "enviroment" {
  default = "tst"
}

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

variable "bits_for_subnets" {
  default = 4
}

### AKS VARS
variable "max_aks_nodes_number" {
  type    = number
  default = 10
}

### PEERING VARS
variable "peeringon" {
  type    = bool
  default = true
}

### HARVOR VARS
variable "harbor_prefix" {
  type    = string
  default = "harbor"
}

variable "notary_prefix" {
  type    = string
  default = "notary"
}
