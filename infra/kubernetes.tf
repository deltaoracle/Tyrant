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

resource "azurerm_role_assignment" "aks_cp_04" {
  scope                = data.azurerm_virtual_network.spoke_vnet.id
  role_definition_name = "Network Contributor"
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

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m" # Optional, defaults to 2 minutes
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.aks_config.azure_rbac_enabled ? [1] : []
    content {
      tenant_id              = var.tenant_id
      admin_group_object_ids = var.aks_config.entra_admin_group_id
      azure_rbac_enabled     = true
    }
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

resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "ingress-nginx"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

locals {
  service_principals_role_assignments = distinct(flatten([
    for role_assignment in var.service_principals_role_assignments : [
      for role in role_assignment.roles : {
        display_name         = role_assignment.display_name,
        role_definition_name = role
      }
    ]
  ]))

  service_principals_role_assignments_loop = { for role_assignment in local.service_principals_role_assignments : "${lower(role_assignment.display_name)}-${lower(replace(role_assignment.role_definition_name, " ", "_"))}" => role_assignment }
}

##
# IAM by service principals on AKS
##
data "azuread_service_principal" "this" {
  for_each = local.service_principals_role_assignments_loop

  display_name = each.value.display_name
}

resource "azurerm_role_assignment" "service_principals" {
  for_each = local.service_principals_role_assignments_loop

  scope = azurerm_kubernetes_cluster.aks.id

  principal_id         = data.azuread_service_principal.this["${lower(each.value.display_name)}-${lower(replace(each.value.role_definition_name, " ", "_"))}"].object_id
  role_definition_name = each.value.role_definition_name
}

##
# Observability
##
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${module.naming.azure_service["monitor_diagnostic_setting"]}-${module.naming.azure_service["container_kubernetes_service"]}-${module.naming.azure_suffix}"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.observability.id

  enabled_log {
    category = "kube-audit"
  }
  enabled_log {
    category = "kube-audit-admin"
  }
  enabled_log {
    category = "kube-apiserver"
  }
  enabled_log {
    category = "kube-controller-manager"
  }
  enabled_log {
    category = "kube-scheduler"
  }
  enabled_log {
    category = "guard"
  }
}
