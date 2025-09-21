output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster."
}

output "aks_kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
  description = "The kubeconfig raw data for the AKS cluster."
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
  description = "The FQDN of the AKS cluster."
}

output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.postgres.name
  description = "The name of the PostgreSQL flexible server."
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
  description = "The FQDN of the PostgreSQL server."
}

output "postgres_connection_string" {
  value     = "postgres://${azurerm_postgresql_flexible_server.postgres.administrator_login}:${azurerm_postgresql_flexible_server.postgres.administrator_password}@${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/${azurerm_postgresql_flexible_server_database.example_db.name}"
  sensitive = true
  description = "The connection string for the PostgreSQL server."
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
  description = "The name of the storage account."
}

output "storage_account_primary_blob_endpoint" {
  value = azurerm_storage_account.storage.primary_blob_endpoint
  description = "The primary blob endpoint of the storage account."
}

output "key_vault_uri" {
  value = azurerm_key_vault.spoke_kv.vault_uri
  description = "The URI of the spoke key vault."
}

output "hub_key_vault_uri" {
  value = data.azurerm_key_vault.hub_kv.vault_uri
  description = "The URI of the hub key vault."
}

output "app_insights_instrumentation_key" {
  value     = azurerm_application_insights.app_insights.instrumentation_key
  sensitive = true
  description = "The instrumentation key for Application Insights."
}

output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
  description = "The endpoint for the OpenAI cognitive account."
}

output "resource_group_name" {
  value = data.azurerm_resource_group.spoke_rg.name
  description = "The name of the resource group for the Tyrant deployment."
}

output "vnet_id" {
  value = data.azurerm_virtual_network.spoke_vnet.id
  description = "The ID of the virtual network."
}

output "aks_subnet_id" {
  value = data.azurerm_subnet.aks_subnet.id
  description = "The ID of the AKS subnet."
}

output "private_endpoints_subnet_id" {
  value = data.azurerm_subnet.private_endpoints_subnet.id
  description = "The ID of the private endpoints subnet."
}