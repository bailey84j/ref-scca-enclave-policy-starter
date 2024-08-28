# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# The following block of locals are used to avoid using
# empty object types in the code
locals {
  empty_list   = []
  empty_map    = tomap({})
  empty_string = ""
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
