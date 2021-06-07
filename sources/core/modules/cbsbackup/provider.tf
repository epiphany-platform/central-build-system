provider "kubernetes" {
  host = var.kube_host

  client_certificate     = base64decode(var.kube_client_cert)
  client_key             = base64decode(var.kube_client_key)
  cluster_ca_certificate = base64decode(var.kube_cluster_ca)
}