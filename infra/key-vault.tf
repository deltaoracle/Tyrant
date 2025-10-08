# key-vault.tf - Azure Key Vault

data "azurerm_client_config" "current" {}

# Spoke Key Vault
resource "azurerm_key_vault" "spoke_kv" {
  name                          = "${module.naming.azure_service["key_vault"]}-${module.naming.azure_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = true
  rbac_authorization_enabled    = true

  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  soft_delete_retention_days = 30
  purge_protection_enabled   = true

  tags = var.tags
}

##
# Private Link
##
# tflint-ignore: terraform_required_providers
resource "azurerm_private_endpoint" "spoke_kv" {
  name                          = "${module.naming.azure_service["private_endpoint"]}-${module.naming.azure_service["key_vault"]}-${module.naming.azure_suffix}"
  custom_network_interface_name = "${module.naming.azure_service["network_interface"]}-${module.naming.azure_service["private_endpoint"]}-${module.naming.azure_service["key_vault"]}-${module.naming.azure_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = data.azurerm_subnet.this[var.private_endpoints_subnet_name].id

  private_service_connection {
    name = "${module.naming.azure_service["private_service_connection"]}-${module.naming.azure_service["key_vault"]}-${module.naming.azure_suffix}"

    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.spoke_kv.id
    subresource_names = [
      "vault",
    ]
  }

  private_dns_zone_group {
    name = "${module.naming.azure_service["dns_zone_group"]}-${module.naming.azure_service["key_vault"]}-${module.naming.azure_suffix}"

    private_dns_zone_ids = ["/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.hub_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
  }

  tags = var.tags
}
