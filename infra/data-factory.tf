resource "azurerm_data_factory" "adf" {
  name                = "${module.naming.azure_service["data_factory"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  managed_virtual_network_enabled = true

  tags = var.tags

  lifecycle {
    # ignore_changes for the main ADF resource, esp github configuration
    ignore_changes = [
      github_configuration,
      vsts_configuration
    ]
  }
}

