provider "azurerm" {
  # version                    = "2.27.0" # Version constraints inside provider configuration blocks are deprecated
  skip_provider_registration = false
  features {}
}

terraform {
  required_version = ">= 0.13.2"
}