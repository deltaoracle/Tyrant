provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "kubernetes" {
  host                   = module.aks.kube_config.host
  client_certificate     = base64decode(module.aks.kube_config.client_certificate)
  client_key             = base64decode(module.aks.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kube_config.host
    client_certificate     = base64decode(module.aks.kube_config.client_certificate)
    client_key             = base64decode(module.aks.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
  }
}

# Reference existing spoke resource group (pre-provisioned)
data "azurerm_resource_group" "spoke_rg" {
  name = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
}

# Reference existing spoke vnet and subnets
data "azurerm_virtual_network" "spoke_vnet" {
  name                = "${module.naming.azure_service["virtual_network"]}-${var.project_name}-${var.environment}"
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

data "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
}

data "azurerm_subnet" "private_endpoints_subnet" {
  name                 = var.private_endpoints_subnet_name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
}

# Preserve original resource group creation (if needed, otherwise remove)
resource "azurerm_resource_group" "rg" {
  count    = 0  # Disable if pre-provisioned; set to 1 if still needed for spoke-specific resources
  name     = "${module.naming.azure_service["resource_group"]}-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# Disable original vnet creation, use data instead
/*
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-tyrant-dev"
  address_space       = ["10.253.20.0/24"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
*/

# Disable original subnet creation, use data instead
/*
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.253.20.0/25"]
}
*/

# AKS (preserve original, update subnet and tags)
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

# PostgreSQL (preserve original, update subnet and tags)
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "${module.naming.azure_service["postgresql_server"]}-${module.naming.azure_suffix}"
  resource_group_name    = data.azurerm_resource_group.spoke_rg.name
  location               = var.location
  version                = "13"
  delegated_subnet_id    = data.azurerm_subnet.private_endpoints_subnet.id
  private_dns_zone_id    = "/subscriptions/${var.subscription_id}/resourceGroups/rg-hub-weu-prod/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
  administrator_login    = "admin"
  administrator_password = "password"  # To move the secret to KV
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  tags                   = var.tags
}

# Storage account (preserve original, update tags)
resource "azurerm_storage_account" "storage" {
  name                     = "${module.naming.azure_service["storage_account"]}${module.naming.azure_suffix}"
  resource_group_name      = data.azurerm_resource_group.spoke_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Disable original app gateway creation
/*
resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-tyrant-dev"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
}
*/

# Add private endpoint, key vault, etc., as before (see original response for full block)