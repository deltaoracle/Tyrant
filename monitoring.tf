# monitoring.tf - Monitoring Resources

# Reference hub Log Analytics Workspace
data "azurerm_log_analytics_workspace" "hub_law" {
  name                = var.hub_log_analytics_workspace_id
  resource_group_name = "rg-hub-weu-prod"
}

# Reference spoke RG
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "${module.naming.azure_service["application_insights"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  workspace_id        = data.azurerm_log_analytics_workspace.hub_law.id
  application_type    = "web"
  tags                = var.tags
}

# Comment out original workspace creation
/*
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${module.naming.azure_service["log_analytics_workspace"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}
*/