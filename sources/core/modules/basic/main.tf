resource "azurerm_resource_group" "rg" {
  name     = "cbs-${var.name}-rg"
  location = var.location
   
  tags = {
    env = var.name
    CreatedWhen = timestamp()
  }
}
