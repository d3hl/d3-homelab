#!/bin/bash
# format-terraform.sh
# Auto-format all Terraform files using terraform fmt

set -e

TERRAFORM_DIR="${1:-.}"

echo "📝 Auto-formatting Terraform code in: $TERRAFORM_DIR"
echo "───────────────────────────────────────────────────"

terraform fmt -recursive "$TERRAFORM_DIR"

echo "✅ Formatting complete!"
echo ""
echo "Changes made to all .tf files in: $TERRAFORM_DIR"
echo "Review changes and commit if satisfied."
