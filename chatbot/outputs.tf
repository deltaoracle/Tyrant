output "resource_group_name" {
  description = "Name of the chatbot resource group"
  value       = azurerm_resource_group.chatbot_rg.name
}

output "resource_group_id" {
  description = "ID of the chatbot resource group"
  value       = azurerm_resource_group.chatbot_rg.id
}

output "resource_group_location" {
  description = "Location of the chatbot resource group"
  value       = azurerm_resource_group.chatbot_rg.location
}

# Application Insights outputs
output "appinsights_id" {
  description = "ID of the Application Insights"
  value       = azurerm_application_insights.chatbot.id
}

output "appinsights_instrumentation_key" {
  description = "Instrumentation key for the Application Insights"
  value       = azurerm_application_insights.chatbot.instrumentation_key
  sensitive   = true
}

output "appinsights_name" {
  description = "Name of the Application Insights"
  value       = azurerm_application_insights.chatbot.name
}

# Azure Bot outputs
output "bot_id" {
  description = "ID of the Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot.id
}

output "bot_name" {
  description = "Name of the Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot.name
}

# Azure AD Application Registration outputs
output "app_registration_client_id" {
  description = "Client ID of the bot registration (from manually created app registration)"
  value       = data.azuread_application.chatbot.client_id
}

output "app_registration_display_name" {
  description = "Display name of the bot registration (from manually created app registration)"
  value       = data.azuread_application.chatbot.display_name
} 