output rg_name {
  value = azurerm_resource_group.rg.name
}

output vnet_name {
  value = azurerm_virtual_network.vnet.name
}

output subnet_id {
  value = azurerm_subnet.subnet.*.id
}

output vnet_id {
  value = azurerm_virtual_network.vnet.id
}
