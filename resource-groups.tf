# resource-groups.tf - Resource Groups

# Use pre-provisioned spoke RG
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

# Create additional spoke RGs if per-env is enabled
resource "azurerm_resource_group" "additional_rg" {
  count    = var.create_per_env ? 1 : 0
  name     = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}-additional"
  location = var.location
  tags     = var.tags
}

# Comment out original creation if pre-provisioned
/*
resource "azurerm_resource_group" "main_rg" {
  name     = "rg-maincluster-all-weu-001"
  location = var.location
  tags     = var.tags
}
*/