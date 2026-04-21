# HCP Terraform on self-hosted GitHub runner

Use this checklist to prepare a self-hosted runner for HCP Terraform upload + run workflows.

## 1) Runner labels

- Register a GitHub self-hosted runner for this repository.
- Ensure it has the `self-hosted` label (default).
- Keep the runner service always-on.

## 2) Required repository secret

- Add `TF_API_TOKEN` in repository secrets.
- The token must be a Terraform Cloud/HCP Terraform user or team token with permission to:
  - read workspace
  - upload configuration versions
  - create runs
  - apply runs (for push/manual apply)

## 3) Workflow defaults

The workflow file is `.github/workflows/hcp-terraform.yml` and defaults to:

- organization: `d3-org`
- workspace: `talos-omni`
- config directory: `./terraform/talos`

Override workspace and directory with `workflow_dispatch` inputs when needed.

## 4) Trigger behavior

- `pull_request`: upload + speculative plan + PR comment
- `push` to `main`: upload + non-speculative run + apply
- `workflow_dispatch`: upload + run, with optional `apply=true`

## 5) Runner prerequisites

Install on the runner host:

- `git`
- `bash`
- outbound HTTPS access to:
  - `app.terraform.io` (or your HCP Terraform hostname)
  - `api.github.com`
  - `github.com`

## 6) First validation run

1. Trigger `workflow_dispatch` with:
   - `tf_workspace=talos-omni`
   - `config_directory=./terraform/talos`
   - `apply=false`
2. Confirm:
   - configuration upload succeeded
   - run link appears in job output
   - run is visible in HCP Terraform workspace
