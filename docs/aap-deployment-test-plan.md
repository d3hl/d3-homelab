# AAP Deployment Test Plan

This runbook validates the AAP 2.6 all-in-one deployment path:

1. GitHub Actions runs on the repository self-hosted runner.
2. The workflow uploads `terraform/aap` to HCP Terraform workspace `aap-container`.
3. HCP Terraform provisions the Proxmox VM.
4. The Red Hat AAP containerized growth installer runs from the AAP host.

## 1. Repo Preflight

Run the local preflight helper from the repository root:

```bash
python tools/check_aap_deployment_preflight.py
```

Expected result:

- Provider targets HCP Terraform organization `d3-org`, project `homelab`, workspace `aap-container`.
- Workflow targets `self-hosted`, uses `terraform/aap`, and applies on `push` and manual `workflow_dispatch`.
- The tracked growth inventory is secret-free.
- `ansible/inventory/inventory-growth.local.ini` is ignored for real deployment secrets.

Also run Terraform static checks:

```bash
terraform -chdir=terraform/aap fmt -check -diff
terraform -chdir=terraform/aap init -backend=false
terraform -chdir=terraform/aap validate
```

## 2. External Preflight

Confirm these outside the repository before creating a live run:

- GitHub secret `TF_API_TOKEN` exists and can upload configuration versions, create runs, and apply runs.
- HCP Terraform workspace `aap-container` has workspace variables for:
  - `virtual_environment_endpoint`
  - `virtual_environment_api_token`
  - `rhel10_template_vm_id`
  - any intended overrides for node, datastore, VLAN, CPU, memory, disk, or IP.
- The HCP Terraform execution environment can reach Proxmox API and SSH on the homelab network.
- The GitHub self-hosted runner is online and can reach GitHub and `app.terraform.io`.

## 3. GitHub Actions Tests

PR test:

- Open a PR touching only `terraform/aap/**` or `.github/workflows/hcp-terraform-aap.yml`.
- Confirm the workflow runs on `self-hosted`.
- Confirm HCP Terraform creates a speculative plan.
- Confirm the PR comment includes the plan summary and HCP run link.
- Confirm no apply occurs for the PR run.

Manual live deployment test:

```bash
gh workflow run hcp-terraform-aap.yml --ref main
```

Expected result:

- The workflow uploads the current `terraform/aap` configuration.
- HCP Terraform creates and applies a run.
- Proxmox shows VM `aap` in pool `aap`.

## 4. Infrastructure Acceptance

After the apply completes, confirm:

- VM runs on the expected Proxmox node, default `nodeD`.
- VM resources match defaults or workspace overrides:
  - 8 vCPU
  - 24576 MiB RAM
  - 160 GiB disk
- Network bridge, VLAN, and IP match the intended workspace values.
- HCP Terraform outputs resolve:
  - `aap_ip`
  - `aap_fqdn`
  - `aap_ssh`
  - `aap_urls`

If the VM exists but is not reachable, validate the RHEL 10 template and VM cloud-init behavior before retrying the workflow.

## 5. AAP Installer Test

Use only the ignored local inventory for real secrets:

```bash
cp ansible/inventory/inventory-growth.ini ansible/inventory/inventory-growth.local.ini
```

Populate `inventory-growth.local.ini` using Ansible Vault, 1Password rendering, or another local secret workflow.
If real installer credentials were ever committed, rotate them before a live deployment.

From the extracted AAP 2.6 containerized installer directory on the AAP host, confirm:

- `inventory-growth.local.ini` uses `ansible_connection=local`.
- All component groups point to `aap.d3hl.site`.
- `bundle_install=true` only when the installer `bundle/` directory exists.

Run:

```bash
ansible-playbook -i inventory-growth.local.ini ansible.containerized_installer.install
```

## 6. Post-Install Acceptance

Confirm:

```bash
podman ps
systemctl --failed
curl -k https://aap.d3hl.site
```

Pass criteria:

- AAP component containers are running.
- No relevant failed services are present.
- Gateway login succeeds.
- Controller, hub, and EDA are reachable through the gateway.

If installation fails, preserve installer logs and container logs before making changes or retrying.
