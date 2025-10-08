# application-gateway.tf - Application Gateway (disabled, use hub's)

# Comment out entire creation - provide backend config to hub admin
/*
resource "azurerm_public_ip" "appgw_pip" {
  name                = "${module.naming.azure_service["public_ip"]}-${module.naming.azure_suffix}"
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  location            = var.location
  allocation_method   = "Dynamic"
  tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${module.naming.azure_service["application_gateway"]}-${module.naming.azure_suffix}"
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  location            = var.location

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = data.azurerm_subnet.appgw_subnet.id  # If needed, but disable for hub
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }

  tags = var.tags
}
*/