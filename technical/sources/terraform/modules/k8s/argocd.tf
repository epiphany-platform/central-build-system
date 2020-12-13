resource "kubernetes_namespace" "argocd_ns" {
  metadata {
    name = var.argocd_ns
  }
}

resource "kubernetes_ingress" "argocd_ingress" {
  metadata {
    annotations = {
      "kubernetes.io/ingress.class"                = "azure/application-gateway"
      "appgw.ingress.kubernetes.io/use-private-ip" = "true"
    }
    name      = var.argocd_ingress
    namespace = kubernetes_namespace.argocd_ns.metadata[0].name
  }
  spec {
    rule {
      host = "${var.argo_prefix}.${var.domain}"
      http {
        path {
          backend {
            service_name = "argocd-server"
            service_port = "https"
          }
        }
      }
    }
    tls {
      hosts       = ["${var.argo_prefix}.${var.domain}"]
      secret_name = var.nginx_secret
    }
  }
}

resource "kubernetes_secret" "argocd_def_secret" {
  metadata {
    name      = var.nginx_secret
    namespace = kubernetes_namespace.argocd_ns.metadata[0].name
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.key.private_key_pem
  }
  lifecycle { ignore_changes = [data] }
}

# Only initial creation after that it will be manged by argocd itself
resource "kubernetes_config_map" "argocd_cm" {
  metadata {
    name      = "argocd-cm"
    namespace = kubernetes_namespace.argocd_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"    = "argocd-cm"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }
  data = {
    "oidc.config" = <<EOF
name: Azure
issuer: https://login.microsoftonline.com/${var.tenant_id}/v2.0
clientID: ${var.client_id}
clientSecret: $oidc.azure.clientSecret
requestedIDTokenClaims:
  groups:
    essential: true
requestedScopes:
  - openid
  - profile
  - email
EOF
    "url"         = "https://${var.domain}"
  }
  lifecycle { ignore_changes = [data] }
}