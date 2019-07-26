resource "kubernetes_cluster_role_binding" "dashboard" {
  metadata {
    name = "kubernetes-dashboard"

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }
}

resource "null_resource" "kube-dashboard-cert" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", data.azurerm_kubernetes_cluster.cluster.*.id)}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/certificate.yaml --kubeconfig ${local_file.kubeconfig.filename}"
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name      = "kubernetes-dashboard"
  chart     = "stable/kubernetes-dashboard"
  version   = "1.4.0"
  namespace = "kube-dashboard"

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set_string {
    name  = "ingress.annotations"
    value = "{ \"kubernetes.io/ingress.class\" = \"nginx\", \"certmanager.k8s.io/cluster-issuer\" = \"letsencrypt-prod\" }"
  }

  set_string {
    name  = "ingress.tls"
    value = "[ hosts = [ \"test.dashboard.platform-services.warnermedia-systems.com\" ], secretName = \"dashboard-tls\" ]"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  depends_on = ["null_resource.kube-dashboard-cert"]
}
