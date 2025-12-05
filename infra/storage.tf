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
  public_network_access_enabled   = var.storage_account.public_network_access_enabled
  allow_nested_items_to_be_public = var.storage_account.blob_anonymous_access_enabled
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.storage_account.account_tier
  account_replication_type        = var.storage_account.replication_type
  tags                            = var.tags

  blob_properties {
    delete_retention_policy {
      days = 90
    }
    container_delete_retention_policy {
      days = 90
    }
  }
}

# Private Endpoint
resource "azurerm_private_endpoint" "storage_pe_blob" {
  name                = "${module.naming.azure_service["private_endpoint"]}-${azurerm_storage_account.storage.name}-blob-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.this[var.private_endpoints_subnet_name].id

  private_service_connection {
    name                           = "${azurerm_storage_account.storage.name}-connection-blob"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name = "${module.naming.azure_service["dns_zone_group"]}-${module.naming.azure_service["storage_account"]}-${module.naming.azure_suffix}"

    private_dns_zone_ids = ["/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.hub_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
  }
}

resource "azurerm_private_endpoint" "storage_pe_file" {
  name                = "${module.naming.azure_service["private_endpoint"]}-${azurerm_storage_account.storage.name}-file-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.this[var.private_endpoints_subnet_name].id

  private_service_connection {
    name                           = "${azurerm_storage_account.storage.name}-connection-file"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name = "${module.naming.azure_service["dns_zone_group"]}-${module.naming.azure_service["storage_account"]}-${module.naming.azure_suffix}"

    private_dns_zone_ids = ["/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.hub_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"]
  }
}

##
# Observability
##
resource "azurerm_monitor_diagnostic_setting" "storage_account_blob" {
  name                       = "${module.naming.azure_service["monitor_diagnostic_setting"]}-${module.naming.azure_service["storage_account"]}-blob-${module.naming.azure_suffix}"
  target_resource_id         = "${azurerm_storage_account.storage.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.observability.id

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_file" {
  name                       = "${module.naming.azure_service["monitor_diagnostic_setting"]}-${module.naming.azure_service["storage_account"]}-file-${module.naming.azure_suffix}"
  target_resource_id         = "${azurerm_storage_account.storage.id}/fileServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.observability.id

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
}
