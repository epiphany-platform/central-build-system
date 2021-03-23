locals {
  backend_address_pool_name_argo     = "argo_backend_addr_pool"
  http_setting_name                  = "http_setting_name"
  frontend_ip_configuration_name_prv = "listener_priv"
  frontend_ip_configuration_name_pub = "listener_pub"
  frontend_pub_port_name             = "https_pub"
}

resource "azurerm_public_ip" "app_gw_pub_ip" {
  allocation_method   = "Static"
  location            = var.location
  name                = "${var.name}-pub_ip"
  resource_group_name = var.rg_name
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "api_gw" {
  location            = var.location
  name                = var.name
  resource_group_name = var.rg_name

  frontend_port {
    name = "httpPort"
    port = 80
  }

  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name_prv
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.appgw_subnet_cidr[0], 37)
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name_pub
    public_ip_address_id = azurerm_public_ip.app_gw_pub_ip.id
  }

  gateway_ip_configuration {
    name      = var.name
    subnet_id = var.subnet_id
  }

  http_listener {
    name                           = local.frontend_ip_configuration_name_prv
    frontend_ip_configuration_name = local.frontend_ip_configuration_name_prv
    frontend_port_name             = "httpPort"
    host_name                      = "${var.argo_prefix}.${var.domain}"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${local.frontend_ip_configuration_name_prv}_argo_rule"
    rule_type                  = "Basic"
    http_listener_name         = local.frontend_ip_configuration_name_prv
    backend_http_settings_name = local.http_setting_name
    backend_address_pool_name  = local.backend_address_pool_name_argo
  }
  
  backend_address_pool {
    name = local.backend_address_pool_name_argo
  }

  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "http"
    request_timeout       = 3
  }

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  tags = {
    CreatedWhen = timestamp()
  }

  # After creation, the ingress controller is managing it
  lifecycle { ignore_changes = all }
}
