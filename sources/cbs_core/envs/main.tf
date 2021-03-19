module "basic" {
  source = "../modules/basic"

  name             = var.project_name
  size             = var.no_vms
  use_public_ip    = var.use_public_ips
  rsa_pub_path     = var.key_path
  location         = data.azurerm_key_vault_secret.cbs_vault["location"].value
  address_space    = data.azurerm_key_vault_secret.cbs_vault["address-space"].value
  bits_for_subnets = var.bits_for_subnets
}

module "aks" {
  source = "../modules/aks"

  name                         = "${var.project_name}-aks"
  rg_name                      = module.basic.rg_name
  subnet_id                    = module.basic.subnet_id[0]
  default_node_pool_max_number = var.max_aks_nodes_number
  location                     = data.azurerm_key_vault_secret.cbs_vault["location"].value
  client_id                    = data.azurerm_key_vault_secret.cbs_vault["client-id"].value
  client_secret                = data.azurerm_key_vault_secret.cbs_vault["client-secret"].value
  tenant_id                    = data.azurerm_key_vault_secret.cbs_vault["tenant-id"].value
  aad_admin_groups             = [data.azurerm_key_vault_secret.cbs_vault["aad-admin-groups"].value]
}

module "peering" {
  source = "../modules/peering"

  peering = var.peeringon

  aks_rg_name   = module.basic.rg_name
  aks_vnet_id   = module.basic.vnet_id
  aks_vnet_name = module.basic.vnet_name

  vm_rg_name   = data.azurerm_key_vault_secret.cbs_vault["vm-rg-name"].value
  vm_vnet_name = data.azurerm_key_vault_secret.cbs_vault["vm-vnet-name"].value
  vm_vnet_id   = data.azurerm_key_vault_secret.cbs_vault["vm-vnet-id"].value
}

module "k8s" {
  source = "../modules/k8s"

  kubeconfig       = module.aks.kubeconfig
  kube_host        = module.aks.kube_host
  kube_client_cert = module.aks.kube_client_cert
  kube_client_key  = module.aks.kube_client_key
  kube_cluster_ca  = module.aks.kube_cluster_ca
  peering_done     = module.peering.peering_done

  argo_prefix               = data.azurerm_key_vault_secret.cbs_vault["argo-prefix"].value
  tekton_prefix             = data.azurerm_key_vault_secret.cbs_vault["tekton-prefix"].value
  domain                    = data.azurerm_key_vault_secret.cbs_vault["domain"].value
  tenant_id                 = data.azurerm_key_vault_secret.cbs_vault["tenant-id"].value
  client_id                 = data.azurerm_key_vault_secret.cbs_vault["client-id"].value
  tekton_operator_container = data.azurerm_key_vault_secret.cbs_vault["tekton-operator-container"].value
  kubernetes_subnet_cidr    = module.basic.subnet_cidrs[0]
  location                  = data.azurerm_key_vault_secret.cbs_vault["location"].value
  name                      = "${var.project_name}-appgw"
  rg_name                   = module.basic.rg_name
  subnet_id                 = module.basic.subnet_id[1]
  appgw_subnet_cidr         = module.basic.subnet_cidrs[1]
  secretJSON                = data.azurerm_key_vault_secret.cbs_vault["agic-json"].value
}

module "harbor" {
  source = "../modules/harbor"

  kube_host        = module.aks.kube_host
  kube_client_cert = module.aks.kube_client_cert
  kube_client_key  = module.aks.kube_client_key
  kube_cluster_ca  = module.aks.kube_cluster_ca

  harbor_url                 = "${var.harbor_prefix}.${data.azurerm_key_vault_secret.cbs_vault["domain"].value}"
  notary_url                 = "${var.notary_prefix}.${data.azurerm_key_vault_secret.cbs_vault["domain"].value}"
  storage_account_name       = azurerm_storage_account.harbor_storage.name
  storage_primary_access_key = azurerm_storage_account.harbor_storage.primary_access_key
  storage_container_name     = azurerm_storage_container.harbor_container.name
}

module "cbsbackup" {
  source = "../modules/cbsbackup"

  kubeconfig       = module.aks.kubeconfig
  kube_host        = module.aks.kube_host
  kube_client_cert = module.aks.kube_client_cert
  kube_client_key  = module.aks.kube_client_key
  kube_cluster_ca  = module.aks.kube_cluster_ca
  domain           = data.azurerm_key_vault_secret.cbs_vault["domain"].value

  harbor_namespace = "harbor"
  argocd_namespace = "argocd"
  storage_name     = azurerm_storage_account.harbor_storage.name
  container_name   = azurerm_storage_container.cbs_backup.name
  sas_token        = data.azurerm_storage_account_sas.backup.sas
}
