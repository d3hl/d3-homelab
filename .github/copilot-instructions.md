# D3 Homelab AI Coding Instructions

## Project Architecture

This is a multi-tier homelab infrastructure project with three main components:
- **Terraform**: Provisions Proxmox VMs and infrastructure  
- **Ansible**: Configures servers and deploys Komodo management platform
- **Authentik**: SSO/identity provider configuration for applications

## Key Infrastructure Patterns

### Proxmox VM Provisioning
- VMs are deployed across 5 Proxmox nodes: `pve10`, `pve14`, `nodeA`, `nodeB`, `nodeC`
- All VMs use cloud-init with standardized user `d3` and SSH key from `/home/d3/.ssh/d3_tf.pub`
- Komodo cluster consists of 5 VMs (kmd1-kmd5) distributed across nodes
- VM templates are cloned, not built from scratch - see `terraform/modules/komodo/kmd*.tf`

### Required Variables Pattern
When editing Terraform modules, always ensure these variables are passed through:
```terraform
# Required in all module calls
ssh_public_key = data.local_file.ssh_public_key.content
virtual_environment_endpoint = var.virtual_environment_endpoint
virtual_environment_api_token = var.virtual_environment_api_token
virtual_environment_username = var.virtual_environment_username
```

### Ansible Inventory Structure
- **pve** group: Proxmox hosts (10.10.10.10, 10.10.10.11, 10.10.10.14)
- **komodo** group: Komodo cluster (10.10.10.30-34)
- All hosts use `ansible_user=d3` with sudo privileges
- Vault-encrypted secrets in playbooks (see `ansible/playbooks/komodo.yml`)

### Komodo Management Platform
- Uses external role `bpbradley.komodo` for deployment
- Supports install/update/uninstall actions via `komodo_action` variable
- Passkeys stored as Ansible Vault encrypted data
- Role manages both periphery agents and server components

## Development Workflows

### Terraform Operations
```bash
# Always run from specific module directory
cd terraform/modules/komodo
terraform plan -var-file="../../../secrets.tfvars"
terraform apply -var-file="../../../secrets.tfvars"
```

### Ansible Deployment
```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/komodo.yml --ask-vault-pass
```

### Authentik Configuration
- Separate Terraform state for SSO applications
- Each app module (proxmox, komodo, beszel, pangolin) requires `AUTHENTIK_TOKEN` and `AUTHENTIK_URL`

## File Conventions

### Cloud-Init Templates
- Located in `terraform/modules/komodo/cloud-config.tf`
- Standardized packages: `qemu-guest-agent`, `net-tools`, `curl`
- Always enables qemu-guest-agent for Proxmox integration

### Ansible Role Structure
- Custom roles in `ansible/roles/` follow standard Ansible layout
- External roles like `bpbradley.komodo` have extensive examples in `examples/`
- Task files use descriptive names: `manage_server.yml`, `update.yml`, `uninstall.yml`

## Critical Dependencies

- **SSH Key Path**: Hardcoded to `/home/d3/.ssh/d3_tf.pub` in cloud-config
- **Datastore**: VMs use `cephVM`, cloud-init snippets use `cFS`
- **Network**: All infrastructure assumes 10.10.10.x subnet
- **User Context**: Everything runs as user `d3` with sudo privileges

When making changes, verify these assumptions still hold across all components.