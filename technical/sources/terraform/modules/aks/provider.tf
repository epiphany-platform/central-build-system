provider "azurerm" {
  version                    = "2.27.0"
  skip_provider_registration = false
  features {}
}

terraform {
  required_version = ">= 0.13.2"
}