locals {
  private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.aks.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.aks.private_fqdn))))
#   private_dns_zone_id   = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_kubernetes_cluster.aks_cluster.node_resource_group}/providers/Microsoft.Network/privateDnsZones/${local.private_dns_zone_name}"
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks-pv-dns-link" {
  name                  = "${var.name}-pvlink"
  resource_group_name   = "MC_${var.rg_name}_${var.name}_${var.location}"
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.cbs-vpn-networkid
}
