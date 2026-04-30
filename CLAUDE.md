# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**d3-homelab** is a homelab infrastructure-as-code project managing a Proxmox-based virtualized environment. It has four main components:

- **Proxmox** — Proxmox Cluster Environment
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

## Proxmox
Manage 4-node Proxmox VE cluster with CEPH storage, VLAN networking, and cloud-init automation.

* Available Tools * 

Python Scripts (uv-based)

- validate_template.py - Validate template health via Proxmox API
- cluster_status.py - Cluster health metrics and node status
- check_ceph_health.py - CEPH storage pool health monitoring
- check_cluster_health.py - Comprehensive cluster diagnostics

All scripts support --help for usage. Run with: uv run tools/<script>.py

### Automation Examples ###

  - Ansible playbooks - Template creation, VLAN bridging setup
  - Terraform modules - VM cloning, multi-node deployments with dual NICs

See examples/ and workflows/ for working configurations.

Core Capabilities

Template Management

- Ubuntu/Debian cloud-init templates with virtio-scsi
- Serial console configuration for cloud images
- Proper boot order and cloud-init CD-ROM (ide2)

Network Infrastructure:

- vmbr3: Corosync (192.168.3.0/24)
- vmbr0: CEPH Public (10.10.10.0/24, MTU 1500)
- vmbr20: CEPH Private (10.20.20.0/24, MTU 1500)
- OpenvSwitch Vlan network

CEPH Storage:

- Multi-OSD configuration
- Public/private network separation
- Health monitoring and diagnostics

API Automation:

- Python via proxmoxer library
- Ansible via community.general.proxmox_* modules
- Terraform via Telmate/proxmox provider

Cluster Architecture (Matrix)

Hardware: 4× Supermicro
Node Specifications for nodeA,nodeB,nodeD,nodeF:
- 2x Intel Xeon Gold 6230 (80C)
- 378GB DDR4
- 1× 1TB boot, 6 x 900G CEPH OSDs
- 2× NICs: 2× 10GbE SFP+
Nodes: nodeA, nodeB, nodeD,nodeF

Quick Examples
Clone template to VM:

bashqm clone 9000 101 --name web-01
qm set 101 --ipconfig0 ip=192.168.3.100/24,gw=192.168.3.1
qm set 101 --net0 virtio,bridge=vmbr0,tag=30
qm start 101
Check cluster health:
bashuv run tools/cluster_status.py
uv run tools/check_ceph_health.py
For Details

reference/ - Cloud-init, networking, API, storage, QEMU guest agent
workflows/ - Cluster formation, CEPH deployment automation
examples/ - Terraform configs, Ansible playbooks
anti-patterns/ - Common mistakes from real deployments


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
