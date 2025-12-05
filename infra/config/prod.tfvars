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
  "snet-postgres",
  "snet-loadbalancer"
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
  kubernetes_version        = "1.32.9"
  automatic_upgrade_channel = "stable"
  network_plugin            = "azure"
  network_policy            = "azure"
  network_data_plane        = "azure"
}

# AKS service principals role assignments
service_principals_role_assignments = [
  {
    display_name = "vml-runner-std-az-devops-01-hub-weu-prod"
    roles        = ["Azure Kubernetes Service Cluster Admin Role"]
  },
  {
    display_name = "vml-runner-std-az-devops-02-hub-weu-prod"
    roles        = ["Azure Kubernetes Service Cluster Admin Role"]
  },
]

aks_subnet_name               = "snet-aks"
private_endpoints_subnet_name = "snet-endpoints"
postgres_subnet_name          = "snet-postgres"
aks_private_dns_zone_id       = "/subscriptions/99e916f5-203c-4c2c-b32a-6527a1ccdb0d/resourceGroups/rg-hub-weu-prod/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"

postgres_server = {
  version         = "16"
  storage_mb      = 2097152
  sku_name        = "GP_Standard_D4s_v3"
  ha_mode         = "ZoneRedundant"
  ha_standby_zone = "2"
}

postgres_admin_login = "pgadmin"

# postgres_databases = {
#   ingestion_dev = {
#     name      = "dpnl_ingestion_dev"
#     charset   = "UTF8"
#     collation = "en_US.utf8"
#   }
# } 

##
# Storage
##
storage_account = {
  public_network_access_enabled = true
  blob_anonymous_access_enabled = false
  account_tier                  = "Standard"
  replication_type              = "ZRS"
}