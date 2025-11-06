##
# Global
##

project_name        = "tyrant"
location            = "westeurope"
subscription_id     = "5d6c5db2-7f61-4253-8602-5018eee3aaef"
resource_group_name = "rg-tyrant-weu-prod"
environment         = "prod"
tags = {
  ApplicationName     = "Tyrant"
  WorkloadName        = "Tyrant"
  DataClassification  = "Medium"
  BusinessCriticality = "High"
  Owner               = "IXM"
  Environment         = "Prod"
  CreatedBy           = "Terraform"
  OperationTeam       = "Tyrant"
}

subnets_name = [
  "snet-aks",
  "snet-endpoints",
  "snet-postgres"
]

##
# Tyrant
##

aks_config = {
  private_cluster_enabled   = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  node_count                = 2
  vm_size                   = "Standard_D2s_v3"
  kubernetes_version        = "1.32.7"
  automatic_upgrade_channel = "stable"
  network_plugin            = "azure"
  network_policy            = "azure"
  network_data_plane        = "azure"
}

aks_subnet_name               = "snet-aks"
private_endpoints_subnet_name = "snet-endpoints"
postgres_subnet_name          = "snet-postgres"
aks_private_dns_zone_id       = "/subscriptions/99e916f5-203c-4c2c-b32a-6527a1ccdb0d/resourceGroups/rg-hub-weu-prod/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"

postgres_server = {
  version    = "16"
  storage_mb = 2097152
  sku_name   = "GP_Standard_D4s_v3"
}

postgres_admin_login = "pgadmin"

# postgres_databases = {
#   ingestion_dev = {
#     name      = "dpnl_ingestion_dev"
#     charset   = "UTF8"
#     collation = "en_US.utf8"
#   }
# } 