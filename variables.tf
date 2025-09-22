# variables.tf - Input Variables

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

variable "location" {
  type    = string
  default = "westeurope"
  description = "Azure region for resources (required by ixm-module-naming)."
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID (set via pipeline)."
}

variable "aks_node_count" {
  type    = number
  default = 2
  description = "Number of nodes in the AKS default node pool."
}

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

variable "aks_subnet_name" {
  type    = string
  default = "aks-subnet"
}

variable "private_endpoints_subnet_name" {
  type    = string
  default = "private-endpoints-subnet"
}

variable "postgres_admin_login" {
  type        = string
  description = "PostgreSQL administrator login."
  sensitive   = true
}

variable "postgres_admin_password" {
  type        = string
  description = "PostgreSQL administrator password."
  sensitive   = true
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
    Environment         = "$(environment)"  # Dynamic from pipeline
    CreatedBy           = "OpenTofu"
    OperationTeam       = "Tyrant"
  }
}