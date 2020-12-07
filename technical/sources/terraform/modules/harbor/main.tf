resource "azurerm_storage_account" "harbor_storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "harbor_container" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.harbor_storage.name
  container_access_type = "private"
}

resource "helm_release" "harbor" {
  name       = "harbor"
  repository = "https://helm.goharbor.io"
  chart      = "harbor"
  version    = "1.3.6"

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

  set {
    name = "expose.ingress.annotations.nginx\\.org/client-max-body-size"
    value = "\"0\""
  }

  set {
    name  = "persistence.imageChartStorage.type"
    value = "azure"
  }

  set {
    name  = "persistence.imageChartStorage.azure.accountname"
    value = azurerm_storage_account.harbor_storage.name
  }

  set {
    name  = "persistence.imageChartStorage.azure.accountkey"
    value = azurerm_storage_account.harbor_storage.primary_access_key
  }

  set {
    name  = "persistence.imageChartStorage.azure.container"
    value = azurerm_storage_container.harbor_container.name
  }

  set {
    name  = "persistence.imageChartStorage.azure.realm"
    value = "core.windows.net"
  }
}
