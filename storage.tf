# storage.tf - Storage Resources

# Reference spoke RG and subnet
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

data "azurerm_virtual_network" "spoke_vnet" {
  name                = "${module.naming.azure_service["virtual_network"]}-${var.project_name}-${var.environment}"
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

data "azurerm_subnet" "private_endpoints_subnet" {
  name                 = var.private_endpoints_subnet_name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "${module.naming.azure_service["storage_account"]}${module.naming.azure_suffix}"
  resource_group_name      = data.azurerm_resource_group.spoke_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Private Endpoint
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${module.naming.azure_service["private_endpoint"]}-${azurerm_storage_account.storage.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  subnet_id           = data.azurerm_subnet.private_endpoints_subnet.id

  private_service_connection {
    name                           = "${azurerm_storage_account.storage.name}-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}