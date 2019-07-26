resource "azurerm_resource_group" "group" {
  name     = "${var.app}-aks-${local.env}"
  location = "${var.location}"
  tags     = "${local.tags}"
}

resource "azurerm_role_assignment" "cluster_admin" {
  count                = "${length(var.cluster_admins)}"
  scope                = "${azurerm_resource_group.group.id}"
  role_definition_name = "Contributor"
  principal_id         = "${element(data.azuread_group.cluster_admin_group.*.id, count.index)}"
}
