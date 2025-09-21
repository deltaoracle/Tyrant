# ai-services.tf - Azure OpenAI and AI services

# Reference naming module (assume called in main.tf)
# module "naming" { ... }

# Reference pre-provisioned spoke RG and private endpoints subnet
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

# Azure OpenAI Service
resource "azurerm_cognitive_account" "openai" {
  name                = "${module.naming.azure_service["cognitive_account"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
  tags                = var.tags
}

# Private Endpoint for OpenAI
resource "azurerm_private_endpoint" "openai_pe" {
  name                = "${module.naming.azure_service["private_endpoint"]}-${azurerm_cognitive_account.openai.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  subnet_id           = data.azurerm_subnet.private_endpoints_subnet.id

  private_service_connection {
    name                           = "${azurerm_cognitive_account.openai.name}-connection"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
}