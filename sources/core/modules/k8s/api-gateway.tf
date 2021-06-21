locals {
  backend_address_pool_name          = "backend_address_pool_name"
  http_setting_name                  = "http_setting_name"
  frontend_ip_configuration_name     = "listener"
  frontend_port_name                 = "https"
  frontend_priv_pub_ip_configuration_name     = "listener_priv_pub"
  frontend_priv_pub_port_name                 = "https"
  frontend_pub_ip_configuration_name = "listener_pub"
  frontend_pub_port_name             = "https_pub"
}

resource "azurerm_public_ip" "app_gw_pub_ip" {
  allocation_method   = "Static"
  location            = var.location
  name                = "cbs-${var.name}-pub-ip"
  resource_group_name = var.rg_name
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "api_gw" {
  location            = var.location
  name                = var.name
  resource_group_name = var.rg_name

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  frontend_ip_configuration {
    name                 = local.frontend_priv_pub_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gw_pub_ip.id
  }

  frontend_port {
    name = local.frontend_priv_pub_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.appgw_subnet_cidr[0], 37)
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  gateway_ip_configuration {
    name      = var.name
    subnet_id = var.subnet_id
  }
  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    name                           = local.frontend_ip_configuration_name
    host_name                      = "${var.tekton_prefix}.${var.domain}"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.frontend_ip_configuration_name
    rule_type                  = "Basic"
    http_listener_name         = local.frontend_ip_configuration_name
    backend_http_settings_name = local.http_setting_name
    backend_address_pool_name  = local.backend_address_pool_name
  }

  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "http"
    request_timeout       = 30
  }

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  # After creation ingress controller is managing it
  lifecycle { ignore_changes = all }
}
