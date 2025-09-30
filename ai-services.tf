# ai-services.tf - Azure OpenAI and AI services

# Reference naming module (assume called in main.tf)
# module "naming" { ... }



# Azure OpenAI Service
resource "azurerm_cognitive_account" "openai" {
  name                  = "${module.naming.azure_service["cognitive_account"]}-${module.naming.azure_suffix}"
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.spoke_rg.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "${module.naming.azure_service["cognitive_account"]}${module.naming.azure_suffix_without_hyphen}"
  tags                  = var.tags
}

# Private Endpoint for OpenAI
resource "azurerm_private_endpoint" "openai_pe" {
  name                = "${module.naming.azure_service["private_endpoint"]}-${azurerm_cognitive_account.openai.name}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  subnet_id           = data.azurerm_subnet.this[var.private_endpoints_subnet_name].id

  private_service_connection {
    name                           = "${module.naming.azure_service["private_service_connection"]}-${module.naming.azure_service["private_endpoint"]}-${azurerm_cognitive_account.openai.name}-${module.naming.azure_suffix}"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name = "${module.naming.azure_service["dns_zone_group"]}-${module.naming.azure_service["cognitive_account"]}-${module.naming.azure_suffix}"

    private_dns_zone_ids = ["/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.hub_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"]
  }

  tags = var.tags
}