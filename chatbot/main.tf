# Resource Group for Chatbot resources
resource "azurerm_resource_group" "chatbot_rg" {
  name     = "${module.naming.azure_service["resource_group"]}-chatbot-${module.naming.azure_suffix}"
  location = var.location
  tags     = var.tags
}

# Application Insights resources
resource "azurerm_application_insights" "chatbot" {
  name                = "${module.naming.azure_service["app_insights"]}-chatbot-${module.naming.azure_suffix}"
  location            = azurerm_resource_group.chatbot_rg.location
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  application_type    = var.application_insights_type
  workspace_id        = data.azurerm_log_analytics_workspace.existing.id
  tags                = var.tags
}

# Azure Bot resources
resource "azurerm_bot_service_azure_bot" "chatbot" {
  name                    = "${module.naming.azure_service["bot_service"]}-chatbot-${module.naming.azure_suffix}"
  resource_group_name     = azurerm_resource_group.chatbot_rg.name
  location                = var.bot_location
  microsoft_app_id        = data.azuread_application.chatbot.client_id
  microsoft_app_type      = "SingleTenant"
  microsoft_app_tenant_id = data.azurerm_client_config.current.tenant_id
  sku                     = var.bot_sku

  endpoint = var.chatbot_endpoint

  tags = var.tags
} 