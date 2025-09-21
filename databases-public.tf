# databases-public.tf - PostgreSQL Databases (made private)

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

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "${module.naming.azure_service["postgresql_server"]}-${module.naming.azure_suffix}"
  resource_group_name    = data.azurerm_resource_group.spoke_rg.name
  location               = var.location
  version                = "13"
  delegated_subnet_id    = data.azurerm_subnet.private_endpoints_subnet.id
  private_dns_zone_id    = "/subscriptions/${var.subscription_id}/resourceGroups/rg-hub-weu-prod/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
  administrator_login    = var.postgres_admin_login
  administrator_password = var.postgres_admin_password
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  tags                   = var.tags
}

# Databases (example for dev/test/prod separation)
resource "azurerm_postgresql_flexible_server_database" "ingestion_dev" {
  name      = "dpnl_ingestion_dev"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Repeat for other DBs: dpnl_ai_dev, scheduler_dev, etc.

# Comment out public access rules
/*
resource "azurerm_postgresql_flexible_server_firewall_rule" "public_access" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
*/