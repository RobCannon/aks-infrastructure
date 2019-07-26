data "azurerm_client_config" "current" {}

data "azuread_service_principal" "service_principal" {
  display_name = "${var.service_principal_display_name}"
}

data "azuread_service_principal" "client_app" {
  display_name = "${var.client_app_display_name}"
}
