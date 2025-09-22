# variables.tf - Input Variables

variable "project_name" {
  type        = string
  default     = "tyrant"
  description = "Project name for naming."
}

variable "environment" {
  type        = string
  description = "Environment: 'dev' or 'prod'."
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "location" {
  type    = string
  default = "westeurope"
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
    Environment         = "Prod"
    CreatedBy           = "OpenTofu"
    OperationTeam       = "Tyrant"
  }
}