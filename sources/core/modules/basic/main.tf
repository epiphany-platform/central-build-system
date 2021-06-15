resource "azurerm_resource_group" "rg" {
  name     = "cbs-${var.name}-rg"
  location = var.location
   
  tags = {
    Env = var.name
    CreatedWhen = timestamp()
  }
}
