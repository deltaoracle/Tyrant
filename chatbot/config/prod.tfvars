##
# Global
##

environment     = "prod"
subscription_id = "5d6c5db2-7f61-4253-8602-5018eee3aaef"

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

# Azure AD App Registration (manually created)
app_registration_client_id = "fea37708-ec64-40aa-bfc1-87dba0971bc2"