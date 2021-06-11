resource "helm_release" "harbor" {
  name       = "harbor"
  repository = "https://helm.goharbor.io"
  chart      = "harbor"
  version    = var.harbor_version

  namespace        = var.namespace
  create_namespace = true
  timeout          = 900

  set {
    name  = "expose.tls.secretName"
    value = var.harbor_tls_secret_name
  }

  set {
    name  = "expose.tls.notarySecretName"
    value = var.notary_tls_secret_name
  }

  set {
    name  = "externalURL"
    value = "https://${var.harbor_url}"
  }

  set {
    name  = "expose.ingress.hosts.core"
    value = var.harbor_url
  }

  set {
    name  = "expose.ingress.hosts.notary"
    value = var.notary_url
  }

  # CBS use Azure application gateway for ingress but its path routing schema is compatible with GCE.
  # Harbor helm chart that we are using, do not support Azure appgw therefore we set GCE here in order
  # to chose correct routing paths in ingress controller. 
  set {
    name = "expose.ingress.controller"
    value = "gce"
  }

  set {
    name  = "expose.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "azure/application-gateway"
  }

  set {
    name  = "expose.ingress.annotations.appgw\\.ingress\\.kubernetes\\.io/use-private-ip"
    value = "true"
    type  = "string"
  }

  set {
    name  = "persistence.imageChartStorage.type"
    value = "azure"
  }

  set {
    name  = "persistence.imageChartStorage.azure.accountname"
    value = var.storage_account_name
  }

  set {
    name  = "persistence.imageChartStorage.azure.accountkey"
    value = var.storage_primary_access_key
  }

  set {
    name  = "persistence.imageChartStorage.azure.container"
    value = var.storage_container_name
  }
  set {
    name  = "persistence.imageChartStorage.azure.realm"
    value = "core.windows.net"
  }
}
