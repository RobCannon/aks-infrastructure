variable "subscription_id_prod" {
  default = ""
}

variable "app" {
  default = "platform-services"
}

variable location {
  default = "eastus2"
}

# Whether the application is available on the public internet,
# also will determine which subnets will be used (public or private)
variable "internal" {
  default = "true"
}

variable "team" {
  default = "Developer Services"
}

variable "contact-email" {
  default = ""
}

variable "customer" {
  default = "Developer Services"
}

locals {
  env = "${terraform.workspace == "default" ? "test" : terraform.workspace}"

  # if prod use azure-platform-services-prod, else use azure-platform-services-dev
  subscription_id = "${terraform.workspace == "prod" ? "" : ""}"

  tags = {
    app             = "${var.app}"
    env             = "${local.env}"
    team            = "${var.team}"
    "contact-email" = "${var.contact-email}"
    customer        = "${var.customer}"
  }
}

variable "service_principal_display_name" {
  default = "srv_platform_services_aks"
}

variable "client_app_display_name" {
  default = "srv_platform_services_aks_client"
}

variable "agent_count" {
  default = 3
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
