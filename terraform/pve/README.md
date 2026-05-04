# Proxmox Terraform Workspace

This workspace uses the BPG Proxmox provider, `bpg/proxmox`, to manage VMs in the `pve` Terraform Cloud workspace.

## Provider

The provider is configured in `provider.tf` with:

- Proxmox API endpoint from `var.virtual_environment_endpoint`
- Proxmox API token from `var.virtual_environment_api_token`
- SSH agent auth for node operations as `var.virtual_environment_username`
- Explicit SSH node mappings for `nodeA`, `nodeB`, `nodeD`, and `nodeF`

The BPG provider docs recommend API token auth. The token format is:

```text
user@realm!tokenid=secret
```

For example:

```text
terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Proxmox Prerequisites

Create a Proxmox API user and token on one Proxmox node:

```bash
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role Administrator
pveum user token add terraform@pve provider --privsep 0
```

Record the token value when Proxmox prints it. It is shown once.

The provider is also configured for SSH. Make sure the SSH user can reach all configured nodes with your SSH agent:

```bash
ssh d3@10.10.10.18 hostname
ssh d3@10.10.10.15 hostname
ssh d3@10.10.10.17 hostname
ssh d3@10.10.10.10 hostname
```

If you use a different SSH user, set `virtual_environment_username`.

## Local Variables

Copy the example variables file and fill in local values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars` is intentionally ignored by git because it contains secrets.

Minimum values:

```hcl
virtual_environment_endpoint  = "https://10.10.10.10:8006/"
virtual_environment_api_token = "terraform@pve!provider=REPLACE_WITH_TOKEN_SECRET"
```

## Run

From this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

This workspace currently creates:

- `komodo-pool`
- cloned VMs `k1`, `k2`, `k3`, and `k4`
- cloned VM `omni-master`

All clones use `ubuntu_template_vm_id`, default `9999`, sourced from `nodeF`.

## GitHub Actions

The workflow `.github/workflows/hcp-terraform-pve.yml` uploads this directory to HCP Terraform and queues a run in:

```text
organization: d3-org
workspace: pve
```

Behavior:

- Pull requests touching `terraform/pve/**` create speculative plan-only runs and comment the plan summary on the PR.
- Pushes to `main` touching `terraform/pve/**` create and apply a run.
- Manual `workflow_dispatch` creates a run and applies it only when `apply` is checked.

Required GitHub repository secret:

```text
TF_API_TOKEN
```

Use an HCP Terraform user or team token with permission to queue plans and apply runs for the `pve` workspace. HCP Terraform must also have the workspace variables required by this configuration, including `virtual_environment_endpoint` and sensitive `virtual_environment_api_token`.

Because the actual Terraform execution happens in HCP Terraform, the `pve` workspace must be able to reach Proxmox. For a private homelab Proxmox endpoint, attach the workspace to an HCP Terraform agent pool running inside the homelab network.
