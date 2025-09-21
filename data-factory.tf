# Reference spoke RG
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

# Data Factory (updated with naming and tags)
resource "azurerm_data_factory" "adf" {
  name                = "${module.naming.azure_service["data_factory"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

# Comment out original if hard-coded
/*
resource "azurerm_data_factory" "original_adf" {
  name = "adf-tyrant-dev"
  # ... original content
}
*/