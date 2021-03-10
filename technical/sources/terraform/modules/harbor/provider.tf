provider "azurerm" {
  # version = "2.27.0"   # Version constraints inside provider configuration blocks are deprecated
  features {}
}

terraform {
  required_version = ">= 0.13.4"
}

provider "helm" {
  kubernetes {
    host = var.kube_host

    client_certificate     = base64decode(var.kube_client_cert)
    client_key             = base64decode(var.kube_client_key)
    cluster_ca_certificate = base64decode(var.kube_cluster_ca)
  }
}
