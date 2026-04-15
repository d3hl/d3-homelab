---
name: proxmox-provisioning
description: "Use when: provisioning VMs on Proxmox with Terraform, creating cloud-init configurations, managing VM templates, scaling Komodo cluster across Proxmox nodes, setting up Proxmox networking and datastores"
applyTo: "terraform/**/*.tf,terraform/**/*.hcl"
---

# Proxmox VM Provisioning Standards

This document defines conventions, best practices, and required patterns for provisioning VMs on Proxmox using Terraform within the d3-homelab project.

## Infrastructure Reference

### Proxmox Nodes
| Node | IP Address | Role | Max VMs |
|------|-----------|------|---------|
| `nodeF` | 10.10.10.10 | Primary | 2-3 |
| `nodeA` | 10.10.10.18 | Secondary | 2-3 |
| `nodeB` | — | Archive/Standby | 1-2 |
| `nodeC` | — | Archive/Standby | 1-2 |
| `nodeD` | — | Archive/Standby | 1-2 |

### Datastores & Resources
| Datastore | Type | Usage | Format |
|-----------|------|-------|--------|
| `cephVM` | Ceph | Production VM disks | Distributed, HA-enabled |
| `cFS` | Local | Cloud-init snippets & templates | YAML/text files |
| VM templates | LVM | Cloning source (ID: 999 ubuntu) | qcow2/img |

### Network Configuration
- **Subnet**: 10.10.10.0/24 (all infrastructure nodes and VMs)
- **Gateway**: 10.10.10.2
- **DNS**: 10.10.10.2
- **DHCP**: Enabled for VMs; static IPs assigned via IPAM (future: netbox/Nautobot)

## Required Variables Pattern

All Terraform modules calling Proxmox resources must include these variables in `provider.tf` and pass them to module calls:

```terraform
variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_api_token" {
  description = "The API token for Proxmox API"
  type        = string
  sensitive   = true
}

variable "virtual_environment_username" {
  type = string
}

variable "virtual_environment_node_name" {
  description = "Proxmox node to provision on"
  type        = string
}

variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks"
  default     = "cephVM"
}
```

**Module Call Example**:
```terraform
module "komodo" {
  source = "../modules/komodo"
  
  virtual_environment_endpoint = var.virtual_environment_endpoint
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_username = var.virtual_environment_username
  virtual_environment_node_name = var.virtual_environment_node_name
  datastore_id = var.datastore_id
}
```

## Cloud-Init Standardization

### Root SSH Key Configuration
**File Path**: `/home/d3/.ssh/d3_tf.pub`  
**User**: `d3` (sudoer with NOPASSWD)  
**Access**: All VMs authorized with this key by default

```hcl
data "local_file" "ssh_public_key" {
  filename = "/home/d3/.ssh/d3_tf.pub"
}
```

### Cloud-Init Template Structure

**Datastore**: `cFS` (cloud-init snippets)  
**Content Type**: `snippets`  
**Naming Convention**: `user-data-<vm-name>.yaml` or `user-data-cloud-config.yaml`

**Minimal Template**:
```cloud-config
#cloud-config
hostname: {vm-name}
timezone: Asia/Singapore
users:
  - default
  - name: d3
    groups:
      - sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - {SSH_PUBLIC_KEY_CONTENT}
    password: {VAULT_ENCRYPTED_PASSWORD}
    sudo: ALL=(ALL) NOPASSWD:ALL
package_update: true
packages:
  - qemu-guest-agent    # Required: VM guest integration
  - net-tools           # Required: Diagnostics
  - curl                # Required: HTTP downloads
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - echo "done" > /tmp/cloud-init.done
```

**Key Requirements**:
- ✓ Always include `qemu-guest-agent`, `net-tools`, `curl`
- ✓ Enable and start `qemu-guest-agent` in runcmd
- ✓ Configure user `d3` as sudoer with NOPASSWD
- ✓ SSH key from `/home/d3/.ssh/d3_tf.pub`
- ✓ Timezone: Asia/Singapore

## VM Resource Configuration

### Cloning Strategy
- **Source Template**: ID `999` (ubuntu base image)
- **Clone Type**: `full = true` (full clone, not linked)
- **Use Case**: All Komodo, Debian, Nautobot VMs

```hcl
clone = {
  source_vm_id = 999
  full         = true
}
```

### Disk Configuration
```hcl
disk = {
  virtio0 = {
    datastore_id = var.datastore_id  # cephVM
    size_gb      = {size}            # 50 for standard
    discard      = "on"              # Trim support
    iothread     = true              # Performance
  }
}
```

**Size Guidelines**:
| VM Type | Size | Use Case |
|---------|------|----------|
| 50 GB | Standard | Komodo nodes, services |
| 100 GB | Data-heavy | Databases, logs |
| 20 GB | Minimal | Agents, monitoring |

### Memory & CPU
```hcl
memory = {
  size    = 4096  # MB
  balloon = 2048  # Min 50% of size
}

cpu = {
  cores = 2
}
```

**Scaling Guidelines**:
- **Komodo nodes**: 4 cores, 4GB RAM minimum
- **Database services**: 4-8 cores, 8-16GB RAM
- **Stateless services**: 2 cores, 2-4GB RAM

## IP Address Planning

### Komodo Cluster (5 VMs)
| VM | IP Address | Node |
|----|-----------|------|
| k1 | 10.10.10.40 | nodeA |
| k2| 10.10.10.41 | nodeB |
| k3 | 10.10.10.42 | nodeD|
| k4 | 10.10.10.43 | nodeF |

### Reserved Ranges
- 10.10.10.0-10: Infrastructure (Proxmox, switches, gateways)
- 10.10.10.40-99: Komodo cluster + management services
- 10.10.10.100-199: Temporary/testing VMs
- 10.10.10.200-254: Future services

## Naming Conventions

### VM Naming Format
```
{service}-{number}
```

**Examples**:
- `kmd1`, `kmd2`, `kmd3` — Komodo nodes
- `debian-1`, `debian-2` — Debian test VMs
- `nautobot-1` — IPAM/Source-of-truth
- `beszel-1` — Monitoring aggregator

**Rules**:
- ✓ Lowercase only
- ✓ Alphanumeric + hyphen
- ✓ Max 32 characters
- ✓ Match hostname in cloud-config

### File Naming in Terraform
```
{service}.tf         — Resource definitions
{service}-{n}.tf     — Individual VM per file (for large clusters)
cloud-config.tf      — Cloud-init templates
provider.tf          — Provider & auth
variables.tf         — Variable definitions
template.tf          — Template references
```

## Terraform Module Layout

**Minimal Module Structure**:
```
terraform/modules/{service}/
├── provider.tf           # Provider config, Proxmox auth
├── variables.tf          # Input variables (required + optional)
├── {service}.tf          # VM resources
├── cloud-config.tf       # Cloud-init templates
└── template.tf           # VM template references
```

**Example Module Call** (from `terraform/pve/`):
```hcl
module "komodo" {
  source = "../modules/komodo"
  
  virtual_environment_endpoint    = var.virtual_environment_endpoint
  virtual_environment_api_token   = var.virtual_environment_api_token
  virtual_environment_username    = var.virtual_environment_username
  virtual_environment_node_name   = "pve10"
  datastore_id                    = "cephVM"
}
```

## Security & Secrets

### API Tokens
- **Storage**: GitHub Secrets or `secrets.tfvars` (git-ignored)
- **Rotation**: Every 90 days
- **Scope**: Minimal Proxmox permissions (VM create/delete/modify only)
- **Format**: `pveum@pve!{token-name}={uuid}`

### SSH Keys
- **Path**: `/home/d3/.ssh/d3_tf.pub` (read-only in cloud-init)
- **User Context**: User `d3` with sudo NOPASSWD
- **Backup**: Keep private key in secure location off-system

### Passwords in Cloud-Init
- ✓ Use Ansible Vault or GitHub Secrets
- ✓ Encrypt passwords in Terraform state: `sensitive = true`
- ✗ NEVER hardcode plain-text passwords in `.tf` files
- ✗ NEVER commit unencrypted `secrets.tfvars`

## Deployment Workflow

### Plan & Apply
```bash
cd terraform/modules/{service}

# Initialize (first time only)
terraform init

# Validate configuration
terraform validate

# Plan changes (dry-run)
terraform plan -var-file="../../../secrets.tfvars"

# Review plan output carefully for:
# - Correct node assignment
# - Proper datastore selection
# - Cloud-init template attachment
# - Network bridging

# Apply with confirmation
terraform apply -var-file="../../../secrets.tfvars"
```

### Verification
After `terraform apply` completes:

1. **Check Proxmox UI**: Verify VMs appear and are running
2. **Confirm qemu-guest-agent**: `qm guest cmd {vmid} ping` (Proxmox CLI)
3. **Verify SSH Access**: `ssh d3@{vm-ip}`
4. **Check Cloud-Init**: `cloud-init status` (on VM)
5. **Confirm Packages**: `apt list --installed | grep qemu-guest-agent`

## Common Pitfalls

| Issue | Cause | Prevention |
|-------|-------|-----------|
| VM won't boot | Wrong template ID (not 999) | Always verify template exists, check cloud-init logs |
| Network misconfiguration | DHCP lease not obtained | Ensure qemu-guest-agent running, check Proxmox network bridge |
| SSH key auth fails | Key path typo, file permissions | Verify `/home/d3/.ssh/d3_tf.pub` exists, is readable |
| State conflicts | Running same module twice | Use Terraform backends to lock state across runs |
| Disk space errors | Undersized or wrong datastore | Check `cephVM` capacity, use `size_gb` >= 50 for standard VMs |

## Related Documentation

- **Terraform Proxmox Provider**: https://registry.terraform.io/providers/bpg/proxmox/latest/docs
- **Cloud-Init Docs**: https://cloud.ubuntu.com/community/
- **Proxmox API**: https://pve.proxmox.com/wiki/Proxmox_VE_API2.0
- **Project README**: [README.md](../../README.md)
- **Ansible Playbooks**: [ansible/README.md](../../ansible/readme.md)
