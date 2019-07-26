resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.app}${local.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  sku                 = "PerGB2018"
  tags                = "${local.tags}"
}

resource "azurerm_log_analytics_solution" "log" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_log_analytics_workspace.log.location}"
  resource_group_name   = "${azurerm_resource_group.group.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.log.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.log.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# data "azurerm_subnet" "private" {
#   name                 = "private"
#   virtual_network_name = "vnet-azure-platform-services-prod"
#   resource_group_name  = "platform-services-prod"
# }

# https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/examples/kubernetes/advanced-networking/main.tf

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.app}-${local.env}"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  dns_prefix          = "${var.app}-${local.env}"
  kubernetes_version  = "1.12.6"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  agent_pool_profile {
    name            = "agentpool"
    count           = "${var.agent_count}"
    vm_size         = "Standard_B4ms"
    os_type         = "Linux"
    os_disk_size_gb = 30

    # vnet_subnet_id  = "${data.azurerm_subnet.private.id}"
  }

  service_principal {
    client_id     = "${data.azuread_service_principal.service_principal.application_id}"
    client_secret = "${data.azurerm_key_vault_secret.service_principal_secret.value}"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.log.id}"
    }
  }

  role_based_access_control {
    enabled = "true"

    azure_active_directory {
      client_app_id     = "${data.azuread_service_principal.client_app.application_id}"
      server_app_id     = "${data.azuread_service_principal.service_principal.application_id}"
      server_app_secret = "${data.azurerm_key_vault_secret.service_principal_secret.value}"
      tenant_id         = "${data.azurerm_client_config.current.tenant_id}"
    }
  }

  tags = "${local.tags}"
}

# Output the kubernetes certificates so they can be used by kubectl
resource "local_file" "kubeconfig" {
  sensitive_content = "${azurerm_kubernetes_cluster.cluster.kube_admin_config_raw}"
  filename          = "${path.module}/.kube/config"
}

# Make sure kube nodes reboot when patched
# https://docs.microsoft.com/en-us/azure/aks/node-updates-kured
resource "null_resource" "kured" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", azurerm_kubernetes_cluster.cluster.*.id)}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/weaveworks/kured/releases/download/1.2.0/kured-1.2.0-dockerhub.yaml --kubeconfig ${local_file.kubeconfig.filename}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]
}
