terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
  }
}

# Naming module for consistent naming convention
module "naming" {
  source       = "git::https://dev.azure.com/IXMSA/ixm-iac/_git/ixm-module-naming?ref=main"
  project_name = var.project_name
  environment  = var.environment
  location     = var.location
}

provider "azurerm" {
  features {}
}

# Data source to get current Azure client configuration (for tenant ID)
data "azurerm_client_config" "current" {}

# Data source to get the existing log analytics workspace
data "azurerm_log_analytics_workspace" "existing" {
  name                = "${module.naming.azure_service["log_analytics_workspace"]}-${module.naming.azure_suffix}"
  resource_group_name = var.shared_resource_group_name
}

# Resource Group for Chatbot resources
resource "azurerm_resource_group" "chatbot_rg" {
  name     = "${module.naming.azure_service["resource_group"]}-chatbot-${module.naming.azure_suffix}"
  location = var.location
  tags     = var.tags
}

# Application Insights resources
resource "azurerm_application_insights" "chatbot" {
  name                = "${module.naming.azure_service["application_insights"]}-chatbot-${module.naming.azure_suffix}"
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
  microsoft_app_id        = azuread_application.chatbot.application_id
  microsoft_app_type      = "SingleTenant"
  microsoft_app_tenant_id = data.azurerm_client_config.current.tenant_id
  sku                     = var.bot_sku

  endpoint = var.chatbot_endpoint

  tags = var.tags
}

# Azure AD Application Registrations for the bot
resource "azuread_application" "chatbot" {
  display_name     = "${module.naming.azure_service["bot_service"]}-chatbot-${module.naming.azure_suffix}"
  sign_in_audience = "AzureADMyOrg" # Single tenant
} 