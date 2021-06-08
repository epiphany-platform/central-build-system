resource "azurerm_storage_account" "harbor_storage" {
  name                     = data.azurerm_key_vault_secret.cbs_vault["harbor-storage-account-name"].value
  resource_group_name      = data.azurerm_key_vault_secret.cbs_vault["harbor-storage-rg-name"].value
  location                 = data.azurerm_key_vault_secret.cbs_vault["location"].value
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "harbor_container" {
  name                  = "cbs-${var.enviroment}-vhds"
  storage_account_name  = azurerm_storage_account.harbor_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "cbs_backup" {
  name                  = "cbs-${var.enviroment}-backup"
  storage_account_name  = azurerm_storage_account.harbor_storage.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "backup" {
  connection_string = azurerm_storage_account.harbor_storage.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2020-01-21"
  expiry = "2023-01-21"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
  }
}
