# storage.tf - Storage Resources

# Storage Account

resource "random_string" "storage_account_suffix" {
  length  = 4
  special = false
}

resource "azurerm_storage_account" "storage" {
  name = substr(
    lower(
    replace("${module.naming.azure_service["storage_account"]}${random_string.storage_account_suffix.result}${var.project_name}${var.environment}", "-", "")),
    0,
    24
  )
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Private Endpoint
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${module.naming.azure_service["private_endpoint"]}-${azurerm_storage_account.storage.name}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.this[var.private_endpoints_subnet_name].id

  private_service_connection {
    name                           = "${azurerm_storage_account.storage.name}-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name = "${module.naming.azure_service["dns_zone_group"]}-${module.naming.azure_service["storage_account"]}-${module.naming.azure_suffix}"

    private_dns_zone_ids = ["/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.hub_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
  }
}