# terraform.tfvars - Variable Values

##
# Global for all environments
##

project_name = "tyrant"
location     = "westeurope"
# hub
hub_acr_name                   = "crshrd0thubweuprod"
hub_key_vault_name             = "kv-shrd35-hub-weu-prod"
hub_log_analytics_workspace_id = "log-hub-weu-prod"
hub_subscription_id            = "99e916f5-203c-4c2c-b32a-6527a1ccdb0d"
hub_resource_group_name        = "rg-hub-weu-prod"
# spoke
create_per_env = false # Set to true for per-env resources
