data "azurerm_key_vault" "cbs" {
  name                = "cbs-${var.enviroment}-kv"
  resource_group_name = "cbs-tools-rg"
}

data "azurerm_key_vault_secret" "cbs_vault" {
  for_each = toset([
    "address-space",
    "agic-json",
    "location",
    "client-id",
    "client-secret",
    "tenant-id",
    "aad-admin-groups",
    "vm-rg-name",
    "vm-vnet-id",
    "vm-vnet-name",
    "argo-prefix",
    "tekton-prefix",
    "domain",
    "tekton-operator-container",
    "harbor-prefix",
    "harbor-tls-secret-name",
    "harbor-storage-account-name",
    "harbor-storage-rg-name"
  ])
  name         = each.value
  key_vault_id = data.azurerm_key_vault.cbs.id
}
