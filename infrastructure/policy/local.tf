# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# The following block of locals are used to avoid using
# empty object types in the code
locals {
  empty_list   = []
  empty_map    = tomap({})
  empty_string = ""
}

# Jsondecode the data source but use known (at plan time) map keys from `alz_archetype_keys`
# and combine with (potentially) known after apply data from the `alz_archetype` data source.
locals {
  alz_policy_assignments_decoded     = { for k in data.alz_archetype_keys.this.alz_policy_assignment_keys : k => jsondecode(data.alz_archetype.this.alz_policy_assignments[k]) }
  alz_policy_definitions_decoded     = { for k in data.alz_archetype_keys.this.alz_policy_definition_keys : k => jsondecode(data.alz_archetype.this.alz_policy_definitions[k]) }
  alz_policy_set_definitions_decoded = { for k in data.alz_archetype_keys.this.alz_policy_set_definition_keys : k => jsondecode(data.alz_archetype.this.alz_policy_set_definitions[k]) }
  alz_role_definitions_decoded       = { for k in data.alz_archetype_keys.this.alz_role_definition_keys : k => jsondecode(data.alz_archetype.this.alz_role_definitions[k]) }
}

# Create a map of role assignment for the scope of the management group
locals {
  policy_role_assignments = data.alz_archetype.this.alz_policy_role_assignments != null ? {
    for pra_key, pra_val in data.alz_archetype.this.alz_policy_role_assignments : pra_key => {
      scope              = pra_val.scope
      role_definition_id = pra_val.role_definition_id
      principal_id       = one(azurerm_management_group_policy_assignment.this[pra_val.assignment_name].identity).principal_id
    }
  } : {}
}

# Get parent management group name from the parent_id
locals {
  parent_management_group_name = element(split("/", data.azurerm_management_group.root.id), length(split("/", data.azurerm_management_group.root.id)) - 1)
}


locals {
  resource_discovery_mode = var.re_evaluate_compliance == true ? "ReEvaluateCompliance" : "ExistingNonCompliant"
}

# The follow locals are used to control non-compliance messages
locals {
  policy_non_compliance_message_enabled                   = var.policy_non_compliance_message_enabled
  policy_non_compliance_message_not_supported_definitions = var.policy_non_compliance_message_not_supported_definitions
  policy_non_compliance_message_default_enabled           = var.policy_non_compliance_message_default_enabled
  policy_non_compliance_message_default                   = var.policy_non_compliance_message_default
  policy_non_compliance_message_enforcement_placeholder   = var.policy_non_compliance_message_enforcement_placeholder
  policy_non_compliance_message_enforced_replacement      = var.policy_non_compliance_message_enforced_replacement
  policy_non_compliance_message_not_enforced_replacement  = var.policy_non_compliance_message_not_enforced_replacement
}
