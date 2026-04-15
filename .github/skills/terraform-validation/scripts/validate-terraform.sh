#!/bin/bash
# validate-terraform.sh
# Comprehensive Terraform validation: format check, syntax validate, and lint
# Usage: ./validate-terraform.sh [directory]

set -e

TERRAFORM_DIR="${1:-.}"
LOG_FILE="/tmp/terraform-validation.log"

echo "🔍 Terraform Validation Suite"
echo "────────────────────────────"
echo "Target: $TERRAFORM_DIR"
echo "Log: $LOG_FILE"
echo ""

# Stage 1: Format Check
echo "📝 Stage 1: Format Check (terraform fmt -check)"
echo "──────────────────────────────────────────────"
if terraform fmt -check -recursive "$TERRAFORM_DIR" 2>&1 | tee -a "$LOG_FILE"; then
    echo "✅ Format check passed"
else
    echo "❌ Format check failed. Run: terraform fmt -recursive $TERRAFORM_DIR"
    exit 1
fi
echo ""

# Stage 2: Syntax Validation
echo "✔️  Stage 2: Syntax Validation (terraform validate)"
echo "──────────────────────────────────────────────────"
if [ -d "$TERRAFORM_DIR/modules" ]; then
    for module in "$TERRAFORM_DIR"/modules/*/; do
        module_name=$(basename "$module")
        echo "  Validating module: $module_name"
        if cd "$module" && terraform init -upgrade 2>&1 | tail -3 && terraform validate 2>&1 | tee -a "$LOG_FILE"; then
            echo "  ✅ $module_name passed"
        else
            echo "  ❌ $module_name failed"
            exit 1
        fi
        cd - > /dev/null
    done
else
    echo "  No modules found; skipping..."
fi
echo ""

# Stage 3: Linting
echo "🔧 Stage 3: Linting (tflint)"
echo "────────────────────────────"
if command -v tflint &> /dev/null; then
    if tflint --config=.tflint.hcl --init 2>&1 | tail -2; then
        echo "  Plugins initialized"
    fi
    
    if tflint --config=.tflint.hcl --recursive "$TERRAFORM_DIR" 2>&1 | tee -a "$LOG_FILE"; then
        echo "✅ Lint check passed"
    else
        echo "⚠️  Lint found issues (see above)"
    fi
else
    echo "⚠️  tflint not installed. Install: https://github.com/terraform-linters/tflint"
fi
echo ""

echo "✅ Validation complete!"
echo "Log saved to: $LOG_FILE"