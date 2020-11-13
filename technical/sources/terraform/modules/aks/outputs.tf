output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks_m.kube_admin_config_raw
}

output "kube_cluster_ca" {
  value = azurerm_kubernetes_cluster.aks_m.kube_admin_config[0].cluster_ca_certificate
}

output "kube_client_key" {
  value = azurerm_kubernetes_cluster.aks_m.kube_admin_config[0].client_key
}

output "kube_client_cert" {
  value = azurerm_kubernetes_cluster.aks_m.kube_admin_config[0].client_certificate
}

output "kube_host" {
  value = azurerm_kubernetes_cluster.aks_m.kube_admin_config[0].host
}