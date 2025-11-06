resource "azurerm_user_assigned_identity" "aks_cp" {
  name                = "${module.naming.azure_service["user_assigned_identity"]}-aks-cp-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "aks_np" {
  name                = "${module.naming.azure_service["user_assigned_identity"]}-aks-np-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "aks_workload_identity" {
  name                = "${module.naming.azure_service["user_assigned_identity"]}-aks-wi-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "aks_cp_01" {
  scope                = data.azurerm_resource_group.spoke_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks_cp.principal_id
}

resource "azurerm_role_assignment" "aks_cp_02" {
  scope                = var.aks_private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_cp.principal_id
}

resource "azurerm_role_assignment" "aks_cp_03" {
  scope                = data.azurerm_subnet.this[var.aks_subnet_name].id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_cp.principal_id
}

resource "azurerm_role_assignment" "aks_np_01" {
  scope                = data.azurerm_resource_group.spoke_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks_np.principal_id
}

resource "azurerm_role_assignment" "aks_np_02" {
  scope                = data.azurerm_resource_group.spoke_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_np.principal_id
}

resource "azurerm_role_assignment" "aks_np_03" {
  scope                = data.azurerm_container_registry.hub_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_np.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${module.naming.azure_service["container_kubernetes_service"]}-${module.naming.azure_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = substr(
    lower(replace("${var.project_name}${var.environment}", "-", "")),
    0,
    24
  )
  private_dns_zone_id = var.aks_private_dns_zone_id

  private_cluster_enabled = var.aks_config.private_cluster_enabled

  kubernetes_version = var.aks_config.kubernetes_version

  oidc_issuer_enabled       = var.aks_config.oidc_issuer_enabled
  workload_identity_enabled = var.aks_config.workload_identity_enabled

  automatic_upgrade_channel = var.aks_config.automatic_upgrade_channel

  node_resource_group = "rg-aks-node-pool-${module.naming.azure_suffix}"

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.aks_np.client_id
    object_id                 = azurerm_user_assigned_identity.aks_np.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_np.id
  }

  network_profile {
    network_plugin     = var.aks_config.network_plugin
    network_policy     = var.aks_config.network_policy
    network_data_plane = var.aks_config.network_data_plane
  }

  default_node_pool {
    name                        = "default${var.environment}"
    node_count                  = var.aks_config.node_count
    vm_size                     = var.aks_config.vm_size
    vnet_subnet_id              = data.azurerm_subnet.this[var.aks_subnet_name].id
    temporary_name_for_rotation = "poolrot"

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }

    tags = var.tags
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_cp.id]
  }

  lifecycle {
    ignore_changes = [
      tags,
      automatic_upgrade_channel
    ]
  }

  depends_on = [
    azurerm_role_assignment.aks_cp_01,
    azurerm_role_assignment.aks_cp_02,
    azurerm_role_assignment.aks_cp_03
  ]

  tags = var.tags

  timeouts {
    create = "2h"
  }
}

resource "azurerm_key_vault_secret" "kube_config" {
  name         = "kube-config-${azurerm_kubernetes_cluster.aks.name}"
  value        = azurerm_kubernetes_cluster.aks.kube_config_raw
  key_vault_id = azurerm_key_vault.spoke_kv.id
  tags         = var.tags
}

resource "azurerm_federated_identity_credential" "aks" {
  name                = "fi-for-mi"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.aks_workload_identity.id

  issuer   = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject  = "system:serviceaccount:be:be-sa"
  audience = ["api://AzureADTokenExchange"]
}

resource "kubernetes_namespace" "current_env" {
  metadata {
    name = var.environment
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}
