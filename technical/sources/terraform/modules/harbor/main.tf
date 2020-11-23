resource "azurerm_storage_account" "harbor_storage" {
  name                     = "harborcbsstorage"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.harbor_storage.name
  container_access_type = "private"
}

resource "helm_release" "harbor" {

  name = "harbor"
  namespace = var.namespace
  create_namespace = true

  timeout = 900

  chart = "${path.module}/chart"
  values = [
    file("${path.module}/chart/values.yaml")
  ]

  set {
    name  = "expose.tls.certSource"
    value = (var.tls_secret_name != "" ? "secret" : "auto")
  }

  set {
    name  = "expose.tls.secret.secretName"
    value = var.tls_secret_name
  }

  set {
    name  = "notary.enabled"
    value = "false"
  }

  set {
    name  = "expose.ingress.hosts.core"
    value = var.url
  }

  set {
    name  = "externalURL"
    value = "https://${var.url}"
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
    value = azurerm_storage_container.example.name
  }

  set {
    name  = "persistence.imageChartStorage.azure.realm"
    value = "core.windows.net"
  }
}
