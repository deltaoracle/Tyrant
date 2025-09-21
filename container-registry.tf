# Container Registry (use hub's ACR, comment out creation)
data "azurerm_container_registry" "hub_acr" {
  name                = var.hub_acr_name
  resource_group_name = "rg-hub-weu-prod"
}

/*
resource "azurerm_container_registry" "acr" {
  name                = "${module.naming.azure_service["container_registry"]}${module.naming.azure_suffix}"  # No hyphens
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false
  tags                = var.tags
}
*/