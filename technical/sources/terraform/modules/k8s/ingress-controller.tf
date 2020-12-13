data "azurerm_subscription" "current" {}

#TODO install it by helm provider
resource "null_resource" "install_ingress_controller" {
  provisioner "local-exec" {
    command = <<EOT
export KUBECONFIG=./tf_kubeconfig
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm upgrade -i ingress-azure application-gateway-kubernetes-ingress/ingress-azure \
--version 1.3.0 \
--set appgw.subscriptionId="${data.azurerm_subscription.current.subscription_id}" \
--set appgw.resourceGroup="${var.rg_name}" \
--set appgw.name="${var.name}" \
--set appgw.usePrivateIP=true \
--set appgw.shared=false \
--set appgw.type=servicePrincipal \
--set appgw.secretJSON="${var.secretJSON}" \
--set rbac.enable=false

EOT
  }
  depends_on = [null_resource.kube_config_create]
}

resource "kubernetes_cluster_role_binding" "appgw-cluster-admin" {
  metadata {
    name = "appgw-cluster-admon"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "ingress-azure"
    namespace = "default"
  }
}
