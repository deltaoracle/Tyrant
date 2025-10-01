##
# Global
##

project_name = "tyrant"
environment  = "prod"
location     = "westeurope"

tags = {
  ApplicationName     = "Tyrant"
  WorkloadName        = "Tyrant-Chatbot"
  DataClassification  = "Medium"
  BusinessCriticality = "High"
  Owner               = "IXM"
  Environment         = "Prod"
  CreatedBy           = "Terraform"
  OperationTeam       = "Tyrant"
}

# Shared Resource Group (from main infrastructure)
shared_resource_group_name = "rg-tyrant-weu-prod"

# Bot endpoint URL - Update this with your actual bot endpoint for prod
chatbot_endpoint = "https://your-prod-bot-endpoint.com/api/messages"

# Azure Bot Configuration - Environment-specific
bot_sku = "S1"