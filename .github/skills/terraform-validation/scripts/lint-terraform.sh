#!/bin/bash
# lint-terraform.sh
# Run tflint with d3-homelab configuration

set -e

TERRAFORM_DIR="${1:-.}"
TFLINT_CONFIG="${2:-.tflint.hcl}"

echo "🔧 Running TFLint on: $TERRAFORM_DIR"
echo "──────────────────────────────────────"

if ! command -v tflint &> /dev/null; then
    echo "❌ tflint not found. Install from: https://github.com/terraform-linters/tflint"
    exit 1
fi

echo "Initializing tflint plugins..."
tflint --config="$TFLINT_CONFIG" --init 2>&1 | tail -3

echo ""
echo "Running linter..."
tflint --config="$TFLINT_CONFIG" --recursive "$TERRAFORM_DIR"

echo ""
echo "✅ Linting complete!"
