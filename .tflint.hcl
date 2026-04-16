plugin "proxmox" {
  enabled = true
}

config {
  format = "compact"
  force  = false
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_provider_version" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  convention = "snake_case"
  format    = "^[a-z_][a-z0-9_]*$"
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_empty_list_equality" {
  enabled = true
}

rule "terraform_empty_map_equality" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = false
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_locals_should_be_used" {
  enabled = false
}

# d3-homelab specific rules
rule "terraform_required_attributes" {
  enabled = false
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}
