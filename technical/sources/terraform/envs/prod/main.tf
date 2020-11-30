module "basic" {
  source = "../../modules/basic"

  name             = var.project_name
  size             = var.no_vms
  use_public_ip    = var.use_public_ips
  location         = var.location
  address_space    = var.address_space
  rsa_pub_path     = var.key_path
  address_prefixes = var.address_prefixes
}

module "aks" {
  source = "../../modules/aks"

  name             = var.project_name
  rg_name          = module.basic.rg_name
  location         = var.location
  subnet_id        = module.basic.subnet_id
  client_id        = var.client_id
  client_secret    = var.client_secret
  tenant_id        = var.tenant_id
  aad_admin_groups = var.aad_admin_groups
}

module "peering" {
  source = "../../modules/peering"

  peering = var.peering

  aks_rg_name   = module.basic.rg_name
  aks_vnet_id   = module.basic.vnet_id
  aks_vnet_name = module.basic.vnet_name

  vm_rg_name   = var.vm_rg_name
  vm_vnet_name = var.vm_vnet_name
  vm_vnet_id   = var.vm_vnet_id
}

module "k8s" {
  source = "../../modules/k8s"

  kubeconfig   = module.aks.kubeconfig
  peering_done = module.peering.peering_done
  subnet_cidr  = var.address_space[0]

  kube_host        = module.aks.kube_host
  kube_client_cert = module.aks.kube_client_cert
  kube_client_key  = module.aks.kube_client_key
  kube_cluster_ca  = module.aks.kube_cluster_ca

  argo_prefix   = var.argo_prefix
  tekton_prefix = var.tekton_prefix
  domain        = var.domain

  tenant_id = var.tenant_id
  client_id = var.client_id

  tekton_operator_container = var.tekton_operator_container
}

module "harbor" {
  source = "../../modules/harbor"

  rg_name              = module.basic.rg_name
  url                  = "${var.harbor_prefix}.${var.domain}"
  tls_secret_name      = var.harbor_tls_secret_name
  storage_account_name = var.harbor_storage_account_name
}
