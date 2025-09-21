# Reference spoke RG and subnet
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

data "azurerm_subnet" "private_endpoints_subnet" {
  name                 = var.private_endpoints_subnet_name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
}

# PostgreSQL (updated, use private DNS from hub)
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "${module.naming.azure_service["postgresql_server"]}-${module.naming.azure_suffix}"
  resource_group_name    = data.azurerm_resource_group.spoke_rg.name
  location               = var.location
  version                = "13"
  delegated_subnet_id    = data.azurerm_subnet.private_endpoints_subnet.id
  private_dns_zone_id    = "/subscriptions/${var.subscription_id}/resourceGroups/rg-hub-weu-prod/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
  administrator_login    = "admin"
  administrator_password = "password"  # Use KV
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  tags                   = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "example_db" {
  name      = "${var.project_name}_${var.environment}"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Comment out original public access
/*
resource "azurerm_postgresql_flexible_server" "original_postgres" {
  name = "postgres-tyrant-dev"
  # ... original content with public_access_enabled = true
}
*/