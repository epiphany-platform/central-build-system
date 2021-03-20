resource "kubernetes_namespace" "nginx_ns" {
  metadata {
    name = var.nginx_ns
  }
}

resource "kubernetes_service" "nginx_svc" {
  metadata {
    name      = var.nginx_svc
    namespace = kubernetes_namespace.nginx_ns.metadata[0].name
    annotations = {
    }
  }
  spec {
    external_traffic_policy = "Local"
    type                    = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }
    port {
      port        = 443
      target_port = 443
      protocol    = "TCP"
      name        = "https"
    }
    selector = {
      app = var.nginx_depl
    }
  }
}

resource "kubernetes_secret" "nginx_def_secret" {
  metadata {
    name      = var.nginx_secret
    namespace = kubernetes_namespace.nginx_ns.metadata[0].name
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.key.private_key_pem
  }
  lifecycle { ignore_changes = [data] }
}
