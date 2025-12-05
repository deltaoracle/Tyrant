# terraform.tfvars - Variable Values

##
# Global for all environments
##

project_name = "tyrant"
location     = "westeurope"
tenant_id    = "203fd445-2bc2-4a4c-93b4-df007cf1dd40"
# hub
hub_acr_name                   = "crshrd0thubweuprod"
hub_key_vault_name             = "kv-shrd35-hub-weu-prod"
hub_log_analytics_workspace_id = "log-hub-weu-prod"
hub_subscription_id            = "99e916f5-203c-4c2c-b32a-6527a1ccdb0d"
hub_resource_group_name        = "rg-hub-weu-prod"
# spoke
create_per_env = false # Set to true for per-env resources
