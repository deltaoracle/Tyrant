##
# Global
##

project_name        = "tyrant"
location            = "westeurope"
subscription_id     = "e6bd9746-705d-4b10-a979-1eaf211a9d5e"
resource_group_name = "rg-tyrant-weu-dev"
tags = {
  ApplicationName     = "Tyrant"
  WorkloadName        = "Tyrant"
  DataClassification  = "Medium"
  BusinessCriticality = "High"
  Owner               = "IXM"
  Environment         = "Dev"
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

aks_vm_size                   = "Standard_D2_v3"
aks_node_count                = 3
aks_subnet_name               = "snet-aks"
private_endpoints_subnet_name = "snet-endpoints"
postgres_subnet_name          = "snet-postgres"

postgres_server = {
  version    = "13"
  storage_mb = 32768
  sku_name   = "GP_Standard_D4s_v3"
}

postgres_admin_login = "pgadmin"

postgres_databases = {
  ingestion_dev = {
    name      = "dpnl_ingestion_dev"
    charset   = "UTF8"
    collation = "en_US.utf8"
  }
}