provider "azurerm" {
  # version = "2.27.0"   # Version constraints inside provider configuration blocks are deprecated
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.13.2"
}