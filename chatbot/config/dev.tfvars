##
# Global
##

environment     = "dev"
subscription_id = "e6bd9746-705d-4b10-a979-1eaf211a9d5e"

tags = {
  ApplicationName     = "Tyrant"
  WorkloadName        = "Tyrant-Chatbot"
  DataClassification  = "Medium"
  BusinessCriticality = "High"
  Owner               = "IXM"
  Environment         = "Dev"
  CreatedBy           = "Terraform"
  OperationTeam       = "Tyrant"
}

# Shared Resource Group (from main infrastructure)
shared_resource_group_name = "rg-tyrant-weu-dev"

# Bot endpoint URL - Update this with your actual bot endpoint for dev
chatbot_endpoint = "https://your-dev-bot-endpoint.com/api/messages"

# Azure Bot Configuration - Environment-specific
bot_sku = "F0"

# Azure AD App Registration (manually created)
app_registration_client_id = "c1469636-cd8f-4f76-aadd-5956dc8eee8b"