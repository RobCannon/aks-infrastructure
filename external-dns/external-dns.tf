# https://hub.helm.sh/charts/stable/external-dns

resource "kubernetes_role" "external-dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

data "azurerm_dns_zone" "warnermedia-systems" {
  provider            = "azurerm.azure-platform-services-prod"
  name                = "warnermedia-systems.com"
  resource_group_name = "platform-services-prod"
}

data "azurerm_client_config" "azure-platform-services-prod" {
  provider = "azurerm.azure-platform-services-prod"
}

resource "kubernetes_secret" "azure-config-file" {
  metadata {
    name      = "external-dns-azure-config-file"
    namespace = "kube-system"
  }

  data {
    "azure.json" = <<EOF
{
    "tenantId":        "${data.azurerm_client_config.azure-platform-services-prod.tenant_id}",
    "subscriptionId":  "${data.azurerm_client_config.azure-platform-services-prod.subscription_id}",
    "aadClientId":     "${data.azuread_service_principal.service_principal.application_id}",
    "aadClientSecret": "${data.azurerm_key_vault_secret.service_principal_secret.value}",
    "resourceGroup":   "${data.azurerm_dns_zone.warnermedia-systems.resource_group_name}"
}
EOF
  }
}

resource "helm_release" "external-dns" {
  name      = "external-dns"
  chart     = "stable/external-dns"
  version   = "1.7.3"
  namespace = "kube-system"

  set {
    name  = "provider"
    value = "azure"
  }

  set {
    name  = "azure.secretName"
    value = "${kubernetes_secret.azure-config-file.metadata.0.name}"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "extraArgs.azure-resource-group"
    value = "${data.azurerm_dns_zone.warnermedia-systems.resource_group_name}"
  }
}
