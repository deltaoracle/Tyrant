# Reference pre-provisioned spoke RG and private endpoints subnet
data "azurerm_resource_group" "spoke_rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "spoke_vnet" {
  name                = "${module.naming.azure_service["virtual_network"]}-${module.naming.azure_suffix}"
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

data "azurerm_subnet" "this" {
  for_each = var.subnets_name

  name                 = "${each.key}-${module.naming.azure_suffix}"
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
}
