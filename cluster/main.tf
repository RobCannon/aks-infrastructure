terraform {
  required_version = "= 0.11.11"

  backend "azurerm" {
    storage_account_name = "platformservicesprodtf"
    container_name       = "tfstate"
    access_key           = ""
    key                  = "aks-infrastructure-cluster.terraform.tfstate"
  }
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "azurerm" {
  alias           = "azure-platform-services-prod"
  version         = "=1.22.0"
  subscription_id = "${var.subscription_id_prod}"
}

provider "azurerm" {
  version         = "=1.22.0"
  subscription_id = "${local.subscription_id}"
}

provider "azuread" {
  version         = "~> 0.2.0"
  subscription_id = "${var.subscription_id_prod}"
}

# Using output of aks build to feed kubernetes provider base on this article
# https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform
# But modified based on this GitHub issues
# https://github.com/terraform-providers/terraform-provider-kubernetes/issues/175

provider "kubernetes" {
  version                = "~> 1.5"
  load_config_file       = false
  host                   = "${azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)}"
}
