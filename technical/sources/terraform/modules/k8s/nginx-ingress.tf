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
      "service.beta.kubernetes.io/azure-load-balancer-internal" = true
    }
  }
  spec {
    external_traffic_policy = "Local"
    type                    = "LoadBalancer"
    load_balancer_ip        = cidrhost(var.subnet_cidr, 37)
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
