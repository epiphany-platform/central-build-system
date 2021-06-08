resource "azurerm_virtual_network" "vnet" {
  name                = "cbs-${var.name}-vnet"
  address_space       = [var.address_space]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "subnet" {
  count                = pow(2, var.bits_for_subnets)

  name                 = "cbs-${var.name}-snet-${count.index}"
  address_prefixes     = [cidrsubnet(var.address_space, var.bits_for_subnets, count.index)]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  enforce_private_link_endpoint_network_policies = count.index == 0
}
