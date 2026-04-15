# TFLint Configuration for d3-homelab
# Place as .tflint.hcl in the workspace root

plugin "terraform" {
  enabled = true
  version = "0.8.2"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"

  rules = [
    "terraform_required_version",
    "terraform_required_providers",
    "terraform_naming_convention",
    "terraform_unused_declarations",
    "terraform_comment_syntax",
  ]
}

plugin "proxmox" {
  enabled = true
  version = "0.2.0"
  source  = "github.com/terraform-linters/tflint-ruleset-proxmox"
}

# d3-homelab specific rules

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  
  # Variable/output naming as snake_case
  convention = "snake_case"
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = false  # Use terraform_unused_variable and _output instead
}

rule "terraform_unused_variable" {
  enabled = true
}

rule "terraform_unused_output" {
  enabled = false  # Outputs may be used by consumers
}

# Custom rules for Proxmox provisioning patterns

rule "terraform_variable_should_be_used" {
  enabled = true
}

# Disable rules that conflict with project conventions
rule "terraform_locals_should_be_used" {
  enabled = false  # Hard-coded values acceptable for infrastructure naming
}

rule "terraform_typed_variables" {
  enabled = true
}
