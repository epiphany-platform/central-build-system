data "azurerm_subscription" "current" {}

resource "helm_release" "agic" {
  name = "ingress-azure"
  chart = "ingress-azure"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  version = "1.3.0"

  set {
    name = "usePrivateIP"
    value = "true"
  }

  set {
    name = "appgw.subscriptionId"
    value = data.azurerm_subscription.current.subscription_id
  }

  set {
    name = "appgw.resourceGroup"
    value = var.rg_name
  }

  set {
    name = "appgw.name"
    value = var.name
  }

  set {
    name = "appgw.shared"
    value = "false"
  }

  set {
    name = "appgw.type"
    value = "servicePrincipal"
  }

  set {
    name = "appgw.secretJSON"
    value = var.secretJSON
  }

  set {
    name = "rbac.enable"
    value = "true"
  }

}

resource "kubernetes_cluster_role_binding" "appgw-cluster-admin" {
  metadata {
    name = "appgw-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "ingress-azure"
    namespace = "default"
  }
}
