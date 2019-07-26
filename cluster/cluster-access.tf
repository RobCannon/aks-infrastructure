data "azuread_group" "cluster_admin_group" {
  count = "${length(var.cluster_admins)}"
  name  = "${element(var.cluster_admins, count.index)}"
}

resource "kubernetes_cluster_role_binding" "cluster-admins" {
  count = "${length(var.cluster_admins)}"

  metadata {
    name = "cluster-admins-${lower(replace(element(data.azuread_group.cluster_admin_group.*.name, count.index)," ","-"))}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "${element(data.azuread_group.cluster_admin_group.*.id, count.index)}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]
}
