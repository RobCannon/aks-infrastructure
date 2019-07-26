# https://hub.helm.sh/charts/stable/cert-manager

# Installation guide for cert-manager
# https://cert-manager.readthedocs.io/en/latest/getting-started/install.html#installing-with-helm

# Need to install cert-manager custom resources
# https://github.com/jetstack/cert-manager/blob/release-0.7/deploy/charts/cert-manager/README.md
# kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.7/deploy/manifests/00-crds.yaml

resource "null_resource" "cert-manager-custom-resources" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", data.azurerm_kubernetes_cluster.cluster.*.id)}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.7/deploy/manifests/00-crds.yaml --kubeconfig ${local_file.kubeconfig.filename}"
  }
}

resource "null_resource" "cert-manager-issuer" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", data.azurerm_kubernetes_cluster.cluster.*.id)}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/cert-manager-issuer.yaml --kubeconfig ${local_file.kubeconfig.filename}"
  }

  depends_on = ["null_resource.cert-manager-custom-resources"]
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    labels {
      "certmanager.k8s.io/disable-validation" = "true"
    }

    name = "cert-manager"
  }
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  chart      = "jetstack/cert-manager"
  repository = "{data.helm_repository.jetstack.metadata.0.name}"
  version    = "0.7.0"
  namespace  = "cert-manager"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "clusterResourceNamespace"
    value = "cert-manager"
  }

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  depends_on = ["kubernetes_namespace.cert-manager", "null_resource.cert-manager-issuer"]
}
