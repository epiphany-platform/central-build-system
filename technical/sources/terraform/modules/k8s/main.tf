resource "null_resource" "kube_config_create" {
  provisioner "local-exec" {
    command = "echo \"${var.kubeconfig}\" > tf_kubeconfig"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "tekton_crd" {
  provisioner "local-exec" {
    #Copied and partially moved to resources from this file https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.16.3/release.yaml"
    command = "kubectl apply --kubeconfig tf_kubeconfig -f ../../modules/k8s/manifests/tekton.yaml"
  }

  depends_on = [null_resource.kube_config_create, kubernetes_namespace.tekton_ns]
}

resource "null_resource" "tekton_dashboard" {
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig tf_kubeconfig -f ../../modules/k8s/manifests/tekton-dashboard-crd.yaml"
  }

  depends_on = [null_resource.kube_config_create, kubernetes_namespace.tekton_ns]
}

resource "null_resource" "argocd" {
  provisioner "local-exec" {
    #
    command = "kubectl apply --kubeconfig tf_kubeconfig -f ../../modules/k8s/manifests/argocd.yaml"
  }

  depends_on = [null_resource.kube_config_create, kubernetes_namespace.argocd_ns, kubernetes_config_map.argocd_cm]
}

#TODO Remove this when each team will have it's own tekton
resource "null_resource" "tekton_global_dashboard" {
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig tf_kubeconfig -f ../../modules/k8s/manifests/tekton-dashboard-release-readonly-original.yaml"
  }

  depends_on = [null_resource.kube_config_create]
}

resource "null_resource" "nginx_ingress" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig tf_kubeconfig apply -f ../../modules/k8s/manifests/ingress.yaml"
  }

  depends_on = [null_resource.kube_config_create]
}

resource "null_resource" "kube_config_destroy" {
  provisioner "local-exec" {
    command = "sleep 10 && rm tf_kubeconfig"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [null_resource.argocd, null_resource.tekton_crd]
}