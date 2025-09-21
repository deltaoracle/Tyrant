# Reference spoke RG and subnet
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
}

# AKS (updated)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${module.naming.azure_service["kubernetes_cluster"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = data.azurerm_subnet.aks_subnet.id
  }
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

# Helm releases (update to pull from hub ACR)
# Example: helm_release "nginx" { repository = var.hub_acr_name ... }

# Comment out original
/*
resource "azurerm_kubernetes_cluster" "original_aks" {
  name = "aks-tyrant-dev"
  # ... original content
}
*/