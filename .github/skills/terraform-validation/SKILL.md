---
name: terraform-validation
description: 'Validate, lint, and format Terraform code using terraform fmt, terraform validate, and tflint. Use for enforcing code quality, catching configuration errors before deployment, ensuring style consistency, and improving infrastructure-as-code maintainability.'
argument-hint: 'Specify the module or file to validate (e.g., "terraform/modules/komodo", "validate all terraform")'
user-invocable: true
---

# Terraform Validation & Linting

Ensure infrastructure code quality, catch errors early, and maintain consistent formatting across Terraform modules. This skill automates code validation, style checking, and best-practice enforcement.

## When to Use

- **Before deploying** infrastructure changes (`terraform apply`)
- **Code reviews** to flag style issues and anti-patterns
- **CI/CD pipelines** to gate merges (automated validation)
- **Module development** to catch errors early
- **Formatting fixes** to auto-correct indentation and structure

## Validation Stages

### Stage 1: Format Check (`terraform fmt`)
Ensures consistent indentation, spacing, and structure.

```bash
# Check formatting (dry-run, no changes)
terraform fmt -check -recursive terraform/

# Auto-fix formatting
terraform fmt -recursive terraform/
```

**What it catches**:
- ✓ Inconsistent indentation (should be 2 spaces)
- ✓ Missing/extra whitespace
- ✓ Argument ordering
- ✓ Bracket placement

### Stage 2: Syntax Validation (`terraform validate`)
Checks configuration structure and completeness.

```bash
# Initialize backend first (required for validation)
terraform init

# Validate syntax and structure
terraform validate
```

**What it catches**:
- ✓ Missing required arguments
- ✓ Invalid resource/module names
- ✓ Type mismatches
- ✓ Unresolved variable references
- ✓ Provider configuration errors

### Stage 3: Linting (`tflint`)
Enforces style, security, and best-practice rules specific to Proxmox provisioning.

```bash
# Run tflint with proxmox config
tflint --config=.tflint.hcl --recursive terraform/

# Specific module
tflint --config=.tflint.hcl terraform/modules/komodo
```

**What it catches**:
- ✗ Hard-coded values (should use variables)
- ✗ Missing resource names (terraform-required-providers)
- ✗ Unused variables and outputs
- ✗ Security issues (exposed secrets patterns)
- ✗ Performance anti-patterns
- ✗ d3-homelab specific rules (e.g., must use `cephVM` datastore, required `qemu-guest-agent`)

## Configuration Files

### tflint Configuration (`.tflint.hcl`)
Located in workspace root. Customized for Proxmox and d3-homelab patterns:

```hcl
# Reference: tfling configuration for d3-homelab Proxmox provisioning
plugin "proxmox" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  convention = "snake_case"
}

# Project-specific
rule "terraform_locals_should_be_used" {
  enabled = false  # Not enforced; flexible naming ok
}

rule "terraform_comment_syntax" {
  enabled = true
}
```

**View/modify**: [.tflint.hcl](./references/.tflint.hcl)

## Procedure: Full Validation Workflow

### 1. **Format Code**
```bash
cd terraform/
terraform fmt -recursive .
```
✓ Auto-fixes formatting to standardized style

### 2. **Validate Syntax**
```bash
# For each module
cd terraform/modules/komodo
terraform init  # Required once per module
terraform validate
```
✓ Checks structure, variables, providers

### 3. **Run Linter**
```bash
cd terraform/
tflint --config=.tflint.hcl --recursive .
```
✓ Checks best practices, security, d3-homelab conventions

### 4. **Review Results**
- **Errors** (RED): Must fix before apply
- **Warnings** (YELLOW): Fix or document exception
- **Info** (BLUE): Advisory; consider improvements

### 5. **Example Output**
```
Error: terraform_required_providers: Missing version constraint for provider "proxmox"
  on modules/komodo/provider.tf:1:

Warning: terraform_unused_variable: Variable "unused_var" is declared but never used
  on modules/komodo/variables.tf:45:

Info: terraform_locals_should_be_used: "hard_coded_value" is hard-coded; consider using locals
  on modules/komodo/komodo.tf:12:
```

## CI/CD Integration

### GitHub Actions Workflow Example
```yaml
name: Terraform Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Format Check
        run: terraform fmt -check -recursive terraform/
      
      - name: Terraform Validate
        run: |
          cd terraform/modules/komodo
          terraform init
          terraform validate
      
      - name: Run TFLint
        uses: terraform-linters/setup-tflint@v4
        with:
          tflint_version: latest
      
      - name: TFLint Check
        run: tflint --config=.tflint.hcl --recursive terraform/
```

See [GitHub Actions workflow](./references/terraform-validation.yaml) for full example.

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| `terraform validate` fails in CI but works locally | Different `terraform init` state | Run `terraform init` in CI before validation |
| `tflint: plugin not found` | Missing plugin installation | Run `tflint --init` once to download plugins |
| Formatting differs after `fmt` | Wrong terraform version | Upgrade terraform to latest; version should be 1.5+ |
| `hard_coded_value` warnings | Values should be variables | Move to `variables.tf`, pass through module calls |
| `unused_variable` errors | Dead code in variables.tf | Remove unused variables or add `#tflint-ignore=terraform_unused_variable` comment |

## Best Practices

✓ **Before commit**: Run all 3 stages (format → validate → lint)  
✓ **CI/CD gates**: Refuse merges that fail validation  
✓ **Automation**: Use pre-commit hooks to auto-validate on save  
✓ **Exceptions**: Document `#tflint-ignore` comments with justification  
✓ **Consistency**: Keep tflint config version-controlled; sync across team  

## Troubleshooting

### Issue: `terraform init` fails in module directory
**Solution**: Ensure `provider.tf` exists in the module with proper backend config.

```bash
# Module directory must have provider.tf
ls terraform/modules/komodo/provider.tf
```

### Issue: tflint says "variable must be used" but it's in a module call
**Solution**: Check that the module input actually passes the variable.

```terraform
# ❌ Wrong: declares var but doesn't use it
variable "datastore_id" { ... }

# ✓ Correct: passes to module
module "komodo" {
  datastore_id = var.datastore_id
}
```

### Issue: "Missing required argument" errors after `terraform validate`
**Solution**: Check all required variables are passed in module calls; see [proxmox-provisioning.instructions.md](../../instructions/proxmox-provisioning.instructions.md#required-variables-pattern) for required variables.

## Scripts

Run validation on any directory:

- [validate-terraform.sh](./scripts/validate-terraform.sh) — Run all 3 stages
- [format-terraform.sh](./scripts/format-terraform.sh) — Format codes only
- [lint-terraform.sh](./scripts/lint-terraform.sh) — Lint only

**Usage**:
```bash
./validate-terraform.sh terraform/modules/komodo
```

## References

- [Terraform formatting docs](https://developer.hashicorp.com/terraform/cli/commands/fmt)
- [Terraform validate docs](https://developer.hashicorp.com/terraform/cli/commands/validate)
- [TFLint documentation](https://github.com/terraform-linters/tflint)
- [Proxmox Provisioning Standards](../../instructions/proxmox-provisioning.instructions.md)