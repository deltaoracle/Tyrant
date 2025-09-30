# AKS (updated)
# Question : What about Kube patching ?
# Question : What about the kube version ?
# Question : what about private cluster ?
# Question : No network profile (network_plugin, network_policy) ?
# Question : No role assignment to pull from ACR (use managed identity) ?
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${module.naming.azure_service["container_kubernetes_service"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = substr(
    lower(
    replace("${var.project_name}${var.environment}", "-", "")),
    0,
    24
  )
  default_node_pool {
    name           = "default"
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = data.azurerm_subnet.this[var.aks_subnet_name].id
    tags           = var.tags
  }
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
  tags = var.tags
}

resource "azurerm_key_vault_secret" "kube_config" {
  name         = "kube-config-${azurerm_kubernetes_cluster.aks.name}"
  value        = azurerm_kubernetes_cluster.aks.kube_config_raw
  key_vault_id = azurerm_key_vault.spoke_kv.id
  tags         = var.tags

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