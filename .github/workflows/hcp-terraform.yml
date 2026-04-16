name: HCP Terraform
# deploy
on:
  pull_request:
    paths:
      - 'terraform/komodo/**'
      - '.github/workflows/hcp-terraform.yml' # ye
  push:
    branches:
      - main
    paths:
      - 'terraform/komodo/**'
      - '.github/workflows/hcp-terraform.yml'
  workflow_dispatch:

env:
  TF_CLOUD_ORGANIZATION: d3-org
  TF_WORKSPACE: komodo
  TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
  CONFIG_DIRECTORY: "./terraform/komodo"

permissions:
  contents: read
  pull-requests: write

jobs:
  terraform-plan:
    if: github.repository == 'd3hl/d3-homelab' 
    name: Plan Changes
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Validate Terraform Cloud inputs
        shell: bash
        run: |
          set -euo pipefail
          [ -n "${TF_CLOUD_ORGANIZATION}" ] || { echo "TF_CLOUD_ORGANIZATION is empty"; exit 1; }
          [ -n "${TF_WORKSPACE}" ] || { echo "TF_WORKSPACE is empty"; exit 1; }
          [ -n "${TF_API_TOKEN}" ] || { echo "TF_API_TOKEN is empty (check repository secret and event type)"; exit 1; }
          [ -d "${CONFIG_DIRECTORY}" ] || { echo "CONFIG_DIRECTORY not found: ${CONFIG_DIRECTORY}"; ls -la; exit 1; }
      - name: Upload Configuration
        uses: hashicorp/tfc-workflows-github/actions/upload-configuration@v1.3.2
        id: plan-upload
        with:
          workspace: ${{ env.TF_WORKSPACE }}
          directory: ${{ env.CONFIG_DIRECTORY }}
          organization: ${{ env.TF_CLOUD_ORGANIZATION }}
          token: ${{ env.TF_API_TOKEN }}
          speculative: true


      - name: Create Plan Run
        uses: hashicorp/tfc-workflows-github/actions/create-run@v1.3.2
        id: plan-run
        with:
          workspace: ${{ env.TF_WORKSPACE }}
          configuration_version: ${{ steps.plan-upload.outputs.configuration_version_id }}
          organization: ${{ env.TF_CLOUD_ORGANIZATION }}
          token: ${{ env.TF_API_TOKEN }}
          plan_only: true
      - name: Get Plan Output
        uses: hashicorp/tfc-workflows-github/actions/plan-output@v1.3.2
        id: plan-output
        with:
          plan: ${{ fromJSON(steps.plan-run.outputs.payload).data.relationships.plan.data.id }}
          
      - name: Update PR
        uses: actions/github-script@v6
        id: plan-comment
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            // 1. Retrieve existing bot comments for the PR
            const { data: comments } = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
            });
            const botComment = comments.find(comment => {
              return comment.user.type === 'Bot' && comment.body.includes('HCP Terraform Plan Output')
            });
            const output = `#### HCP Terraform Plan Output
              \`\`\`
              Plan: ${{ steps.plan-output.outputs.add }} to add, ${{ steps.plan-output.outputs.change }} to change, ${{ steps.plan-output.outputs.destroy }} to destroy.
              \`\`\`
              [HCP Terraform Plan](${{ steps.plan-run.outputs.run_link }})
              `;
            // 3. Delete previous comment so PR timeline makes sense
            if (botComment) {
              github.rest.issues.deleteComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: botComment.id,
            });
            }
            github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
            });
  terraform-apply:
    name: Apply Changes
    runs-on: self-hosted
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Load secret from 1Password
        uses: 1password/load-secrets-action@v4
        with:
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
          TF_API_TOKEN: op://d3HL/Terraform Proxmox GitOps.env/TF_API_TOKEN
      - name: Validate Terraform Cloud inputs
        shell: bash
        run: |
          set -euo pipefail
          [ -n "${TF_CLOUD_ORGANIZATION}" ] || { echo "TF_CLOUD_ORGANIZATION is empty"; exit 1; }
          [ -n "${TF_WORKSPACE}" ] || { echo "TF_WORKSPACE is empty"; exit 1; }
          [ -n "${TF_API_TOKEN}" ] || { echo "TF_API_TOKEN is empty (check 1Password item path and runner access)"; exit 1; }
          [ -d "${CONFIG_DIRECTORY}" ] || { echo "CONFIG_DIRECTORY not found: ${CONFIG_DIRECTORY}"; ls -la; exit 1; }
      - name: Upload Configuration
        uses: hashicorp/tfc-workflows-github/actions/upload-configuration@v1.3.2
        id: apply-upload
        with:
          workspace: ${{ env.TF_WORKSPACE }}
          directory: ${{ env.CONFIG_DIRECTORY }}
          organization: ${{ env.TF_CLOUD_ORGANIZATION }}
          token: ${{ env.TF_API_TOKEN }}
      - name: Create Apply Run
        uses: hashicorp/tfc-workflows-github/actions/create-run@v1.3.2
        id: apply-run
        with:
          workspace: ${{ env.TF_WORKSPACE }}
          configuration_version: ${{ steps.apply-upload.outputs.configuration_version_id }}
          organization: ${{ env.TF_CLOUD_ORGANIZATION }}
          token: ${{ env.TF_API_TOKEN }}
      - name: Apply
        uses: hashicorp/tfc-workflows-github/actions/apply-run@v1.3.2
        if: fromJSON(steps.apply-run.outputs.payload).data.attributes.actions.IsConfirmable
        id: apply
        with:
          run: ${{ steps.apply-run.outputs.run_id }}
          comment: "Apply Run from GitHub Actions CI ${{ github.sha }}"

#  tflint:
 #   name: TFLint
  #  runs-on: ubuntu-latest
   # steps:
     # - name: Checkout code
    #    uses: actions/checkout@v4

#      - name: Setup TFLint
 #       uses: terraform-linters/setup-tflint@v4

#      - name: Init TFLint
 #       run: tflint --init

#      - name: Run TFLint
 #       working-directory: terraform
  #      run: tflint --config=.tflint.hcl --recursive
