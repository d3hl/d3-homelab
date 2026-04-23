# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**d3-homelab** is a homelab infrastructure-as-code project managing a Proxmox-based virtualized environment. It has four main components:

- **Terraform** — provisions Proxmox VMs
- **Ansible** — configures servers and deploys the Komodo management platform
- **Omni** — on-premises Kubernetes cluster management (Talos Linux) with Dex OIDC
- **Authentik** — SSO/identity provider for applications (separate Terraform state)

## Key Infrastructure Assumptions

These are hardcoded across the codebase — verify they still hold when making changes:

- **SSH Key**: `/home/d3/.ssh/d3_tf.pub` (used in all cloud-init configs)
- **Datastores**: VM disks on `cephVM`, cloud-init snippets on `cFS`
- **Network**: All infrastructure on `10.10.10.x` subnet
- **Proxmox nodes**: `pve10`, `pve14`, `nodeA`, `nodeB`, `nodeC`
- **User**: Everything runs as `d3` with sudo privileges
- **Ubuntu template VM ID**: `999`
- **Komodo cluster IPs**: `10.10.10.30–34`

## Terraform

```bash
# Always run from the specific root module directory, not from modules/
cd terraform/komodo
terraform init
terraform plan -var-file="../../secrets.tfvars"
terraform apply -var-file="../../secrets.tfvars"

cd terraform/pve
terraform plan -var-file="../../secrets.tfvars"
```

Required variables passed through all module calls:
```terraform
ssh_public_key                = data.local_file.ssh_public_key.content
virtual_environment_endpoint  = var.virtual_environment_endpoint
virtual_environment_api_token = var.virtual_environment_api_token
virtual_environment_username  = var.virtual_environment_username
```

VMs are **cloned** from a template (ID `999`), never built from scratch. Cloud-init standardizes packages: `qemu-guest-agent`, `net-tools`, `curl`.

CI/CD uses **Terrateam** (`.terrateam/` config) for automated plan/apply on PRs via a self-hosted GitHub Actions runner (`.github/workflows/tf.yml`).

## Ansible

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/komodo.yml --ask-vault-pass
```

- **Inventory groups**: `pve` (Proxmox hosts: 10.10.10.10, .11, .14), `komodo` (cluster: 10.10.10.30–34)
- All hosts: `ansible_user=d3`
- Secrets are **Ansible Vault** encrypted — always use `--ask-vault-pass` or configure vault password file
- Komodo deployment uses the external role `bpbradley.komodo` (in `ansible/roles/bpbradley.komodo/`); control the action via `komodo_action: install|update|uninstall`

## Omni (on-prem Kubernetes management)

Omni runs via Docker Compose with Dex for OIDC. Secrets are injected from **1Password** using the `op` CLI.

```bash
cd omni

# 1. Inject secrets from 1Password vault "d3hl" into config files
./start.sh

# 2. Start Omni + Dex
docker compose up -d
```

`start.sh` renders all `.tpl` template files into their final forms (`.env`, `omni.asc`, certs, `dex.yaml`) using `op inject`. Never commit rendered secrets — only `.tpl` files are tracked.

SSL certificates: `omni/scripts/setup-ssl.sh` (Cloudflare-based), GPG etcd key: `omni/scripts/setup-gbg.sh`.

Cluster config templates are in `omni/templates/` (omniconfig, talosconfig).

## Secrets Management

| Layer | Method |
|---|---|
| Terraform | `.tfvars` files (git-ignored, stored externally) |
| Ansible | Ansible Vault encrypted vars |
| Omni/Docker | 1Password (`op inject`) with `TARGET_ENV=d3hl` |
| Authentik Terraform | `AUTHENTIK_TOKEN` + `AUTHENTIK_URL` env vars |
