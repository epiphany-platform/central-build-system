resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location
}

module "vms" {
  source = "./modules/vms"

  instances     = var.size
  name          = var.name
  rg_name       = azurerm_resource_group.rg.name
  vnet_id       = azurerm_virtual_network.vnet.id
  location      = var.location
  service       = "all"
  use_public_ip = var.use_public_ip
  subnet_id     = azurerm_subnet.subnet.id

  tf_key_path = var.rsa_pub_path
}
