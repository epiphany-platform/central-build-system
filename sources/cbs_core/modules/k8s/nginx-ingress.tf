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
