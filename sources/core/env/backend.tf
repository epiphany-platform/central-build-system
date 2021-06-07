terraform {
  backend "azurerm" {
    resource_group_name  = "your_value"
    storage_account_name = "your_value"
    container_name       = "your_value"
    key                  = "your_value"
  }
}
