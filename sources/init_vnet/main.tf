resource "azurerm_resource_group" "rg" {
  name     = "cbs-${var.name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "cbs-${var.name}-vnet"
  address_space       = var.address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "subnet" {
  name                 = "cbs-${var.name}-snet"
  address_prefixes     = var.address_prefixes
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "pubip" {
  name                    = "cbs-${var.name}-pubip"
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = "30"
  sku                     = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                          = "cbs-${var.name}-nic"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  enable_accelerated_networking = "false"

  ip_configuration {
    name                          = "vm-ipconf-0"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nic-nsg-0"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

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
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.name}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_D1_v2"
  network_interface_ids = [azurerm_network_interface.nic.id]

  disable_password_authentication = true

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.tf_key_path)
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "18.04.202006101"
  }

  os_disk {
    name                 = "cbs-${var.name}-disk"
    caching              = "ReadWrite"
    disk_size_gb         = "32"
    storage_account_type = "Standard_LRS"
  }

  custom_data = base64encode(file("init.sh"))
}
