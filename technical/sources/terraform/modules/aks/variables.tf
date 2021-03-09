variable "name" {
  type        = string
  description = "Cluster name"
}

variable "rg_name" {
  type        = string
  description = "Existing resource group name"
}

variable "location" {
  type        = string
  description = "Location of your cluster"
}

variable "subnet_id" {
  type        = string
  description = "subnet id"
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
  description = "Leave empty if no integration needed"
}

variable "default_node_pool_min_number" {
  type        = number
  default     = 1
  description = "number of default node pools nodes"
}

variable "default_node_pool_max_number" {
  type        = number
  default     = 1
  description = "number of default node pools nodes"
}

### Vars with defaults
variable "dns_prefix" {
  type        = string
  default     = "cluster-dns"
  description = "dns_prefix"
}

variable "private_cluster" {
  type        = bool
  default     = true
  description = "private cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.17.13"
  description = "your kubernetes version"
}

variable "default_node_pool_vm_size" {
  type        = string
  default     = "Standard_B4ms"
  description = "size of default node pools nodes"
}

variable "network_plugin" {
  type    = string
  default = "azure"
}

variable "network_policy" {
  type    = string
  default = "calico"
}

variable "network_docker_bridge_cidr" {
  type    = string
  default = "172.17.0.1/16"
}

variable "network_dns_service_ip" {
  type    = string
  default = "10.0.6.10"
}

variable "network_service_cidr" {
  type    = string
  default = "10.0.6.0/24"
}

variable "network_outbound_type" {
  type    = string
  default = "loadBalancer"
}

variable "network_load_balancer_sku" {
  type    = string
  default = "standard"
}

variable "rbac_enabled" {
  type    = bool
  default = true
}

variable "aad_integration_enabled" {
  type    = bool
  default = true
}
