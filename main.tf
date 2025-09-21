# Comment out original vnet creation
/*
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-tyrant-dev"
  address_space       = ["10.253.20.0/24"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
*/

# Use pre-provisioned vnet
data "azurerm_virtual_network" "spoke_vnet" {
  name                = "${module.naming.azure_service["virtual_network"]}-${var.project_name}-${var.environment}"
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
}

# Update AKS to use pre-provisioned subnet
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${module.naming.azure_service["kubernetes_cluster"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = data.azurerm_subnet.aks_subnet.id  # Use data source
  }
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}