output "public_ip" {
  value = azurerm_public_ip.pubip.ip_address
}

output "vm_rg_name" {
  value = "\"${azurerm_resource_group.rg.name}\""
}

output "vm_vnet_name" {
  value = "\"${azurerm_virtual_network.vnet.name}\""
}
output "vm_vnet_id" {
  value = "\"${azurerm_virtual_network.vnet.id}\""
}