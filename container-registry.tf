# container-registry.tf - Azure Container Registry (use hub's)

# Reference hub ACR
data "azurerm_container_registry" "hub_acr" {
  name                = var.hub_acr_name
  resource_group_name = "rg-hub-weu-prod"
}

# Grant AKS pull access to hub ACR (if needed)
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = data.azurerm_container_registry.hub_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Comment out creation
/*
resource "azurerm_container_registry" "acr" {
  name                = "${module.naming.azure_service["container_registry"]}${module.naming.azure_suffix}"
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false
  tags                = var.tags
}
*/