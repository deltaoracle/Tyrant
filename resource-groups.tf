# Resource Group (use pre-provisioned spoke RG)
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

# Comment out creation
/*
resource "azurerm_resource_group" "rg" {
  name     = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}
*/