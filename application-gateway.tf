# Application Gateway (disabled, we use hub's internal app gateway)
# Provide backend details to hub admin: e.g., AKS IPs, port 443, health probe /healthz

/*
resource "azurerm_application_gateway" "appgw" {
  name                = "${module.naming.azure_service["application_gateway"]}-${module.naming.azure_suffix}"
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  location            = var.location
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
  # ... original content
}
*/