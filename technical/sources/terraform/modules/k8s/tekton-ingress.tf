resource "kubernetes_namespace" "tekton_ns" {
  metadata {
    name = var.tekton_ns
    labels = {
      "app.kubernetes.io/instance" = "default"
      "app.kubernetes.io/part-of"  = "tekton-pipelines"
    }
  }
}

resource "kubernetes_secret" "tekton_def_secret" {
  metadata {
    name      = var.nginx_secret
    namespace = kubernetes_namespace.tekton_ns.metadata[0].name
  }
  type = "Opaque"
  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.key.private_key_pem
  }
}

resource "kubernetes_ingress" "tekton_ingress" {
  metadata {
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/ssl-passthrough"    = "true"
    }
    name      = "tekton-ingress"
    namespace = kubernetes_namespace.tekton_ns.metadata[0].name
  }
  spec {
    rule {
      host = "${var.tekton_prefix}.${var.domain}"
      http {
        path {
          backend {
            service_name = "tekton-dashboard"
            service_port = "9097"
          }
        }
      }
    }
    tls {
      hosts       = ["${var.tekton_prefix}.${var.domain}"]
      secret_name = var.nginx_secret
    }
  }
}