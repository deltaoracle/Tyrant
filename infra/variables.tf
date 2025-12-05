# variables.tf - Input Variables
##
# Global
##

variable "project_name" {
  type        = string
  default     = "tyrant"
  description = "Project name for naming convention (required by ixm-module-naming)."
}

variable "environment" {
  type        = string
  description = "Environment to deploy (must be 'dev', 'uat', or 'prod', set via pipeline)."
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be 'dev', 'uat', or 'prod' as per ixm-module-naming."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name spoke"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure region for resources (required by ixm-module-naming)."
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "subnets_name" {
  type        = set(string)
  description = "List of subnets name"
}

variable "create_per_env" {
  type        = bool
  default     = false
  description = "Whether to create environment-specific resources."
}

variable "tags" {
  type = map(string)
  default = {
    ApplicationName     = "Tyrant"
    WorkloadName        = "Tyrant"
    DataClassification  = "Medium"
    BusinessCriticality = "High"
    Owner               = "IXM"
    Environment         = "Dev"
    CreatedBy           = "OpenTofu"
    OperationTeam       = "Tyrant"
  }
}

##
# Hub (for cross-subscription resources)
##

variable "hub_acr_name" {
  type    = string
  default = "crshrd0thubweuprod"
}

variable "hub_key_vault_name" {
  type    = string
  default = "kv-shrd35-hub-weu-prod"
}

variable "hub_log_analytics_workspace_id" {
  type    = string
  default = "log-hub-weu-prod"
}

variable "hub_subscription_id" {
  type        = string
  description = "Hub subscription ID for cross-subscription resources."
}

variable "hub_resource_group_name" {
  type        = string
  description = "Hub resource group name for cross-resource group resources."
}

##
# Kubernetes
##

variable "aks_private_dns_zone_id" {
  type        = string
  description = "Private DNS Zone ID for the AKS cluster."
}

variable "aks_node_count" {
  type        = number
  default     = 2
  description = "Number of nodes in the AKS default node pool."
}

variable "aks_subnet_name" {
  type    = string
  default = "aks-subnet"
}

variable "private_endpoints_subnet_name" {
  type    = string
  default = "private-endpoints-subnet"
}

variable "aks_config" {
  description = "aks cluster config"
  type = object({
    private_cluster_enabled   = bool
    oidc_issuer_enabled       = bool
    workload_identity_enabled = bool
    node_count                = number
    vm_size                   = string
    kubernetes_version        = string
    automatic_upgrade_channel = string
    network_plugin            = string
    network_policy            = string
    network_data_plane        = string
    azure_rbac_enabled        = optional(bool, false)
    entra_admin_group_id      = optional(list(string), [])
  })
}

variable "service_principals_role_assignments" {
  type = list(object({
    display_name : string
    roles = list(string)
  }))
  description = "Assigning role to service principals for the project"
}

##
# Databases
##

variable "postgres_subnet_name" {
  type    = string
  default = "postgres-subnet"
}

variable "postgres_server" {
  type = object({
    version         = string
    storage_mb      = number
    sku_name        = string
    ha_mode         = string
    ha_standby_zone = optional(string)
  })
  default = {
    version    = "13"
    storage_mb = 32768
    sku_name   = "GP_Gen5_2"
    ha_mode    = "SameZone"
  }

}

variable "postgres_admin_login" {
  type        = string
  description = "PostgreSQL administrator login."
  sensitive   = true
}

variable "postgres_databases" {
  type = map(object({
    name      = string
    charset   = string
    collation = string
  }))
  default     = {}
  description = "List of PostgreSQL databases to create."

}

##
# Observability
##
variable "log_analytics_workspace_sku" {
  description = "The SKU of the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_workspace_retention_in_days" {
  description = "The retention in days of the Log Analytics workspace."
  type        = number
  default     = 90
}

##
# Storage
##
variable "storage_account" {
  type = object({
    public_network_access_enabled = bool
    blob_anonymous_access_enabled = bool
    account_tier                  = string
    replication_type              = string
  })
  description = "Configure storage account."
}
