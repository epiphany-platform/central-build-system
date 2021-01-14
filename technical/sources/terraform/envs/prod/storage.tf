resource "azurerm_storage_account" "harbor_storage" {
  name                     = data.azurerm_key_vault_secret.cbs_vault["harbor-storage-account-name"].value
  resource_group_name      = module.basic.rg_name
  location                 = data.azurerm_key_vault_secret.cbs_vault["location"].value
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "harbor_container" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.harbor_storage.name
  container_access_type = "private"
}
