# Quick Reference: Terraform Validation Commands

## Format Checking & Fixing

```bash
# Check if formatting is needed (no changes)
terraform fmt -check terraform/

# Recursively check all .tf files
terraform fmt -check -recursive terraform/

# Auto-fix formatting
terraform fmt -recursive terraform/
```

## Syntax Validation

```bash
# Initialize (required once per module)
cd terraform/modules/komodo
terraform init

# Validate syntax
terraform validate

# Check with specific backend
terraform validate -backend=false  # Skip backend validation
```

## TFLint Best Practices

```bash
# Initialize plugins (first time)
tflint --init --config=.tflint.hcl

# Run linter recursively
tflint --config=.tflint.hcl --recursive terraform/

# Lint specific module
tflint --config=.tflint.hcl terraform/modules/komodo/

# Output as JSON
tflint --config=.tflint.hcl --format json terraform/

# Show rule details
tflint --config=.tflint.hcl --verbose terraform/
```

## Complete Validation Flow

```bash
#!/bin/bash
# Full validation before terraform apply

echo "1. Format check..."
terraform fmt -check -recursive terraform/ || exit 1

echo "2. Syntax validation..."
cd terraform/modules/komodo
terraform init
terraform validate || exit 1

echo "3. Linting..."
cd ../.
tflint --config=.tflint.hcl --recursive terraform/ || exit 1

echo "✅ All checks passed!"
```

## Common Issues

| Error | Solution |
|-------|----------|
| `terraform: init required` | Run `terraform init` in the module directory first |
| `tflint: plugin not found` | Run `tflint --init --config=.tflint.hcl` |
| `format differs` | Upgrade terraform to 1.5+; run `terraform fmt` |
| `variable unused` | Remove from `variables.tf` or use in module call |
| `hard-coded value` | Use `locals` or `variables` instead of string literals |

## Help & Documentation

```bash
# Help for each command
terraform fmt -help
terraform validate -help
tflint --help

# TFLint rules
tflint --list-rules --config=.tflint.hcl
```
