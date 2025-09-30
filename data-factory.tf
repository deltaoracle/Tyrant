# data-factory.tf - Azure Data Factory

# Data Factory
# Question : No private endpoint available for Data Factory ?
resource "azurerm_data_factory" "adf" {
  name                = "${module.naming.azure_service["data_factory"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

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