# Data source to get current Azure client configuration (for tenant ID)
data "azurerm_client_config" "current" {}

# Data source to get the existing log analytics workspace
data "azurerm_log_analytics_workspace" "existing" {
  name                = "${module.naming.azure_service["log_analytics_workspace"]}-${module.naming.azure_suffix}"
  resource_group_name = var.shared_resource_group_name
}

# Data source to reference the manually created Azure AD App Registration
data "azuread_application" "chatbot" {
  client_id = var.app_registration_client_id
}