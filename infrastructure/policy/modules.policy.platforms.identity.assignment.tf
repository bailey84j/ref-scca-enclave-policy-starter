# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy Policy Definitions for Azure Policy in the Identity Management Group
DESCRIPTION: The following components will be options in this deployment
             * Policy Definitions
AUTHOR/S: jspinella
*/

##################
# Network
##################

# Deploy Network Policy Assignments
module "mod_platforms_identity_configure_network_configuration_initiative_assignment" {
  source              = "azurenoops/overlays-policy/azurerm//modules/policySetAssignment/managementGroup"
  version             = "~> 2.0"
  initiative          = module.mod_platforms_identity_configure_network_configuration_initiative[0].initiative
  count = var.settings.identity_management_group_policies.enabled ? 1 : 0
  assignment_scope     = var.settings.identity_management_group_policies.create ? azurerm_management_group.identity[0].id : data.azurerm_management_group.identity[0].id
  assignment_location = var.default_location

  # resource remediation options
  re_evaluate_compliance = var.re_evaluate_compliance
  skip_remediation       = var.skip_remediation
  skip_role_assignment   = var.skip_role_assignment
  role_assignment_scope  = data.azurerm_management_group.root.id # using explicit scopes

  # built-ins that deploy/modify require role_definition_ids be present
  role_definition_ids = [
    data.azurerm_role_definition.contributor.id
  ]

  # assignment parameters
  assignment_parameters = {
    ports               = var.listofPortsToDeny,                                       #  Ports to be denied
    allowedRanges       = var.listOfAllowedIPAddressesforNSGs,                         #  IP ranges to be allowed
    vnetRegion          = var.default_location,                                        #  Region of the VNET
    nsgRegion           = var.default_location,                                        #  Region of the NSG
    storageId           = var.settings.workspace.create ? azurerm_storage_account.anoa_hub_storage[0].id : data.azurerm_storage_account.anoa_hub_storage[0].id,            #  Storage Account ID
    workspaceResourceId = var.settings.workspace.create ? azurerm_log_analytics_workspace.anoa_laws[0].id : data.azurerm_log_analytics_workspace.anoa_laws[0].id,           #  Log Analytics Workspace ID
    workspaceRegion     = var.default_location,                                        #  Region of the Log Analytics Workspace
    workspaceId         = var.settings.workspace.create ? azurerm_log_analytics_workspace.anoa_laws[0].workspace_id : data.azurerm_log_analytics_workspace.anoa_laws[0].workspace_id, #  Log Analytics Workspace ID
    networkWatcherRG    = "NetworkWatcherRG",                                          #  Network Watcher Resource Group
    networkWatcherName  = "NetworkWatcher_${var.default_location}",                    #  Network Watcher Name
  }

  # 
  assignment_metadata = {
    version  = "1.0.0"
    category = "Network"
    anoaCloudEnvironments = [
      "AzureCloud",
      "AzureUSGovernment",
    ]
  }
}

####################
# Monitoring
####################

# Deploy Key Vault Policy Assignments
module "mod_platforms_identity_deploy_azure_monitor_baseline_identity_initiative_assignment" {
  source              = "azurenoops/overlays-policy/azurerm//modules/policySetAssignment/managementGroup"
  version             = "~> 2.0"
  initiative          = module.mod_platforms_identity_deploy_azure_monitor_baseline_initiative[0].initiative
  count = var.settings.identity_management_group_policies.enabled ? 1 : 0
  assignment_scope     = var.settings.identity_management_group_policies.create ? azurerm_management_group.identity[0].id : data.azurerm_management_group.identity[0].id
  assignment_location = var.default_location

  # resource remediation options
  re_evaluate_compliance = var.re_evaluate_compliance
  skip_remediation       = var.skip_remediation
  skip_role_assignment   = var.skip_role_assignment
  role_assignment_scope  = data.azurerm_management_group.root.id # using explicit scopes

  # built-ins that deploy/modify require role_definition_ids be present
  role_definition_ids = [
    data.azurerm_role_definition.contributor.id
  ]

  # 
  assignment_metadata = {
    version  = "1.0.0"
    category = "Monitoring"
    anoaCloudEnvironments = [
      "AzureCloud",
      "AzureUSGovernment",
    ]
  }
}
