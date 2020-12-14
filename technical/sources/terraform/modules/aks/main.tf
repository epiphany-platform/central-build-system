resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.rg_name
  dns_prefix              = var.dns_prefix
  private_cluster_enabled = var.private_cluster
  kubernetes_version      = var.kubernetes_version
  default_node_pool {
    name                = substr(join("", [replace(var.name, "-", ""), "dnp"]), 0, 12)
    vm_size             = var.default_node_pool_vm_size
    vnet_subnet_id      = var.subnet_id
    enable_auto_scaling = true
    min_count           = var.default_node_pool_min_number
    max_count           = var.default_node_pool_max_number
  }
  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    docker_bridge_cidr = var.network_docker_bridge_cidr
    dns_service_ip     = var.network_dns_service_ip
    service_cidr       = var.network_service_cidr
    outbound_type      = var.network_outbound_type
    load_balancer_sku  = var.network_load_balancer_sku
  }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  role_based_access_control {
    enabled = var.rbac_enabled
    azure_active_directory {
      managed                = var.aad_integration_enabled
      tenant_id              = var.tenant_id
      admin_group_object_ids = var.aad_admin_groups
    }
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }
    azure_policy {
      enabled = false
    }
    http_application_routing {
      enabled = false
    }
    kube_dashboard {
      enabled = false
    }
    oms_agent {
      enabled = false
    }
  }
}
