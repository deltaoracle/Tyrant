# monitoring.tf - Monitoring Resources

# Spoke Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "observability" {
  name                = "${module.naming.azure_service["log_analytics_workspace"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_workspace_retention_in_days

  tags = merge({ ApplicationName = "Log Analytics Workspace" }, var.tags)
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "${module.naming.azure_service["app_insights"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.observability.id
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