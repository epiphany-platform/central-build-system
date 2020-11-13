output "private_ips" {
  value = module.vms.private_ips
}

output "public_ips" {
  value = module.vms.public_ips
}

output "vm_names" {
  value = module.vms.vm_names
}

output rg_name {
  value = azurerm_resource_group.rg.name
}

output vnet_name {
  value = azurerm_virtual_network.vnet.name
}

output subnet_id {
  value = azurerm_subnet.subnet.id
}

output vnet_id {
  value = azurerm_virtual_network.vnet.id
}