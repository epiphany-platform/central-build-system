resource "null_resource" "kube_config_create" {
  provisioner "local-exec" {
    command = "echo \"${var.kubeconfig}\" > tf_kubeconfig"
  }
  triggers = {
    always_run = timestamp()
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

resource "null_resource" "tekton-triggers" {
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig tf_kubeconfig -f ../../modules/k8s/manifests/tekton-triggers.yaml"
  }

  depends_on = [null_resource.kube_config_create]
}

resource "null_resource" "operator" {
  provisioner "local-exec" {
    command = "cat <<EOF | kubectl apply --kubeconfig tf_kubeconfig -f - \n${templatefile("${path.module}/manifests/operator.tmpl", { OPERATOR_CONTAINER = var.tekton_operator_container })}"
  }

  depends_on = [null_resource.kube_config_create]
}

resource "null_resource" "kube_config_destroy" {
  provisioner "local-exec" {
    command = "rm tf_kubeconfig"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [null_resource.argocd, null_resource.tekton_crd, null_resource.kube_config_create, null_resource.install_ingress_controller, null_resource.operator]
}