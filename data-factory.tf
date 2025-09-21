# data-factory.tf - Azure Data Factory

# Reference spoke RG
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

# Data Factory
resource "azurerm_data_factory" "adf" {
  name                = "${module.naming.azure_service["data_factory"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Example Integration Runtime (if original had it)
resource "azurerm_data_factory_integration_runtime_self_hosted" "ir" {
  name            = "${module.naming.azure_service["data_factory_integration_runtime"]}-${module.naming.azure_suffix}"
  data_factory_id = azurerm_data_factory.adf.id
}