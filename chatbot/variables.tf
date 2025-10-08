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

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure region for resources (required by ixm-module-naming)."
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}

# Shared Resource Group (from main infrastructure)
variable "shared_resource_group_name" {
  description = "Name of the shared resource group from main infrastructure"
  type        = string
}

# Bot endpoint URL
variable "chatbot_endpoint" {
  description = "Endpoint URL for the chatbot"
  type        = string
  default     = "https://your-bot-endpoint.com/api/messages"
}

# Application Insights Configuration
variable "application_insights_type" {
  description = "Application Insights type for chatbot resources"
  type        = string
  default     = "web"
}

# Azure Bot Configuration
variable "bot_location" {
  description = "Azure Bot Service location (must be Global)"
  type        = string
  default     = "Global"
}

variable "bot_sku" {
  description = "Azure Bot Service SKU"
  type        = string
  default     = "F0"
} 