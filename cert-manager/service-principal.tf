data "azurerm_key_vault" "vault" {
  provider            = "azurerm.azure-platform-services-prod"
  name                = "platform-services"
  resource_group_name = "platform-services-keys"
}

# The secret name does not allow underscores, so change underscores to dashes
data "azurerm_key_vault_secret" "service_principal_secret" {
  provider     = "azurerm.azure-platform-services-prod"
  name         = "${replace(var.service_principal_display_name, "_", "-")}"
  key_vault_id = "${data.azurerm_key_vault.vault.id}"
}
