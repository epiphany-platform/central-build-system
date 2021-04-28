resource "azurerm_virtual_network_peering" "vm_to_aks" {
  count                     = var.peering ? 1 : 0
  name                      = "${var.vm_rg_name}---${var.aks_rg_name}"
  remote_virtual_network_id = var.aks_vnet_id
  resource_group_name       = var.vm_rg_name
  virtual_network_name      = var.vm_vnet_name
  allow_gateway_transit     = true
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "aks_to_vm" {
  count                     = var.peering ? 1 : 0
  name                      = "${var.vm_rg_name}---${var.aks_rg_name}"
  remote_virtual_network_id = var.vm_vnet_id
  resource_group_name       = var.aks_rg_name
  virtual_network_name      = var.aks_vnet_name
  allow_forwarded_traffic   = true
  use_remote_gateways       = true
}

output "peering_done" {
  value = "true"
}
