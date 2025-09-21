# Reference spoke RG
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

data "azurerm_key_vault" "hub_kv" {
  name                = var.hub_key_vault_name
  resource_group_name = "rg-hub-weu-prod"
}

# Spoke Key Vault (updated)
resource "azurerm_key_vault" "spoke_kv" {
  name                       = "${module.naming.azure_service["key_vault"]}-${module.naming.azure_suffix}"
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.spoke_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  tags                       = var.tags
}

data "azurerm_client_config" "current" {}

# Comment out original
/*
resource "azurerm_key_vault" "original_kv" {
  name = "kv-tyrant-dev"
  # ... original content
}
*/