resource "azurerm_public_ip" "pubip" {
  count                   = var.use_public_ip != true ? 0 : var.instances
  name                    = "${var.name}-${var.service}-${count.index}-pubip"
  location                = var.location
  resource_group_name     = var.rg_name
  allocation_method       = "Static"
  idle_timeout_in_minutes = "30"
  sku                     = "Standard"
}

resource "azurerm_network_interface" "nic" {
  count                         = var.instances
  name                          = "${var.name}-${var.service}-${count.index}-nic"
  location                      = var.location
  resource_group_name           = var.rg_name
  enable_accelerated_networking = "false"

  ip_configuration {
    name                          = "vm-ipconf-0"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.pubip.*.id) > 0 ? element(concat(azurerm_public_ip.pubip.*.id, list("")), count.index) : ""
  }
}

resource "azurerm_network_security_group" "nsg" {
  count               = var.use_public_ip != true ? 0 : 1
  name                = "vm-nic-nsg-0"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg-assoc" {
  count                     = var.use_public_ip != true ? 0 : var.instances
  network_interface_id      = azurerm_network_interface.nic.*.id[count.index]
  network_security_group_id = azurerm_network_security_group.nsg.*.id[0]
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.instances
  name                  = "${var.name}-${var.service}-${count.index}"
  location              = var.location
  resource_group_name   = var.rg_name
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  disable_password_authentication = true

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.tf_key_path)
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    name                 = "${var.name}-${var.service}-${count.index}-disk"
    caching              = "ReadWrite"
    disk_size_gb         = "32"
    storage_account_type = "Premium_LRS"
  }
}
