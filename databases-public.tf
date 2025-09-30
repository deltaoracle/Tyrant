# databases-public.tf - PostgreSQL Databases (made private)

# PostgreSQL Flexible Server Password
resource "random_password" "pgadmin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}



# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                          = "${module.naming.azure_service["postgresql_flexible_server"]}-${module.naming.azure_suffix}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.postgres_server.version
  delegated_subnet_id           = data.azurerm_subnet.this[var.postgres_subnet_name].id
  private_dns_zone_id           = "/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.hub_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com"
  public_network_access_enabled = false
  administrator_login           = var.postgres_admin_login
  administrator_password        = random_password.pgadmin_password.result
  storage_mb                    = var.postgres_server.storage_mb
  sku_name                      = var.postgres_server.sku_name
  tags                          = var.tags
}

# Store pgadmin password in Key Vault
resource "azurerm_key_vault_secret" "pgadmin_password" {
  name         = "pgadmin-password-${azurerm_postgresql_flexible_server.postgres.name}"
  value        = random_password.pgadmin_password.result
  key_vault_id = azurerm_key_vault.spoke_kv.id
}

# Databases (example for dev/test/prod separation)
resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each  = var.postgres_databases != null ? var.postgres_databases : {}
  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = each.value.charset
  collation = each.value.collation

  lifecycle {
    prevent_destroy = true
  }
}

# To create other DB, add config in tfvars files
# Example:
# postgres_databases = {
#   ingestion_dev = { name = "dpnl_ingestion_dev", charset = "UTF8", collation = "en_US.utf8" }
#   ingestion_test = { name = "dpnl_ingestion_test", charset = "UTF8", collation = "en_US.utf8" }
#   ingestion_prod = { name = "dpnl_ingestion_prod", charset = "UTF8", collation = "en_US.utf8" }
# }