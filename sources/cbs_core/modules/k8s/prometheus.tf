resource "helm_release" "prometheus" {
  name = "prometheus"
  chart = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"

  #TODO determine proper chart version
  #version = "1.3.0"

  set {
    name  = "prometheus.ingress.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.ingress.annotations.appgw\\.ingress\\.kubernetes\\.io/use-private-ip"
    value = "true"
    type = "string"
  }

  set {
    name  = "prometheus.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "azure/application-gateway"
  }

  set {
    name  = "prometheus.ingress.hosts[0]"
    value = "prometheus.${var.domain}"
  }

  set {
    name  = "prometheus.ingress.paths[0]"
    value = "/"
  }

  # set {
  #   name  = "prometheus.ingress.tls[0]"
  #   value = "hosts"
  # }
}

