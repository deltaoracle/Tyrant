# Include naming module (assume included in main.tf or via include)
# module "naming" { ... }  # Reference from naming.tf

# Reference pre-provisioned spoke RG and subnet
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

data "azurerm_subnet" "private_endpoints_subnet" {
  name                 = var.private_endpoints_subnet_name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
}

# AI Services (updated with naming, tags, and private endpoint)
resource "azurerm_cognitive_account" "openai" {
  name                = "${module.naming.azure_service["cognitive_account"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
  tags                = var.tags
}

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

# Comment out any original hard-coded or hub-conflicting resources
/*
resource "azurerm_cognitive_account" "original_openai" {
  name                = "oai-tyrant-dev"  # Hard-coded example
  # ... original content
}
*/