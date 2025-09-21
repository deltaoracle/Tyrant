# key-vault.tf - Azure Key Vault

# Reference spoke RG
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

# Reference hub KV for certs
data "azurerm_key_vault" "hub_kv" {
  name                = var.hub_key_vault_name
  resource_group_name = "rg-hub-weu-prod"
}

data "azurerm_client_config" "current" {}

# Spoke Key Vault
resource "azurerm_key_vault" "spoke_kv" {
  name                        = "${module.naming.azure_service["key_vault"]}-${module.naming.azure_suffix}"
  location                    = var.location
  resource_group_name         = data.azurerm_resource_group.spoke_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  tags                        = var.tags
}

# Access Policy (example for current user)
resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.spoke_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]

  storage_permissions = [
    "Get",
  ]
}