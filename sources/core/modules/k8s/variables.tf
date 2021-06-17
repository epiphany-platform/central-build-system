variable "kubeconfig" {}

variable "kube_host" {}

variable "kube_cluster_ca" {}

variable "kube_client_key" {}

variable "kube_client_cert" {}

variable "kubernetes_subnet_cidr" {}

variable "appgw_subnet_cidr" {}

variable "domain" {}

variable "tekton_prefix" {}

variable "argo_prefix" {}

variable "tenant_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "tekton_operator_container" {}

variable "location" {}

variable "rg_name" {}

variable "name" {}

variable "subnet_id" {}

variable "secretJSON" {}

variable "argocd_ns" {
  default = "argocd"
}

variable "tekton_ns" {
  default = "tekton-pipelines"
}

variable "operator_ns" {
  default = "bs-operator-system"
}
variable "peering_done" {}

variable "nginx_ns" {
  default = "nginx-ingress"
}

variable "nginx_sa" {
  default = "nginx-ingress"
}

variable "nginx_cr" {
  default = "nginx-ingress"
}

variable "nginx_crb" {
  default = "nginx-ingress"
}

variable "nginx_depl" {
  default = "nginx-ingress"
}

variable "nginx_secret" {
  default = "default-server-secret"
}

variable "nginx_cm" {
  default = "nginx-config"
}

variable "nginx_svc" {
  default = "nginx-ingress"
}

variable "tekton_ingerss" {
  default = "tekton-ingress"
}

variable "argocd_ingress" {
  default = "argocd-ingress"
}

variable "tls_key_algorithm" {
  default = "RSA"
}
