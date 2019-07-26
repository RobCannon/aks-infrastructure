terraform {
  required_version = "= 0.11.11"

  backend "azurerm" {
    storage_account_name = "platformservicesprodtf"
    container_name       = "tfstate"
    access_key           = ""
    key                  = "aks-infrastructure-kubernetes-dashboard.terraform.tfstate"
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

data "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.app}-${local.env}"
  resource_group_name = "${var.app}-aks-${local.env}"
}

provider "kubernetes" {
  version                = "~> 1.5"
  load_config_file       = false
  host                   = "${data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host}"
  client_certificate     = "${base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)}"
  client_key             = "${base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)}"
}

provider "helm" {
  version         = "~> 0.9"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.13.1"
  service_account = "tiller"

  kubernetes {
    load_config_file       = false
    host                   = "${data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host}"
    client_certificate     = "${base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)}"
    client_key             = "${base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)}"
  }
}

# Output the kubernetes certificates so they can be used by kubectl
resource "local_file" "kubeconfig" {
  sensitive_content = "${data.azurerm_kubernetes_cluster.cluster.kube_admin_config_raw}"
  filename          = "${path.module}/.kube/config"
}
