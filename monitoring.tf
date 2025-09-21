# Reference hub LAW
data "azurerm_log_analytics_workspace" "hub_law" {
  name                = var.hub_log_analytics_workspace_id
  resource_group_name = "rg-hub-weu-prod"
}

# Application Insights (updated)
resource "azurerm_application_insights" "app_insights" {
  name                = "${module.naming.azure_service["application_insights"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  workspace_id        = data.azurerm_log_analytics_workspace.hub_law.id
  application_type    = "web"
  tags                = var.tags
}

# Comment out original LAW creation
/*
resource "azurerm_log_analytics_workspace" "original_law" {
  name = "law-tyrant-dev"
  # ... original content
}
*/