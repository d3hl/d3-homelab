---
source_agent: create-playbook
target_agent: ansible-generator
timestamp: "2026-05-01T00:00:00Z"
target_path: ansible/playbooks/manage-vm.yml
target_type: playbook
---

# Scaffolding Bundle

## Target Path
ansible/playbooks/manage-vm.yml

## User Requirements
- Manage Proxmox VM lifecycle (start, stop, create from template, remove)
- Credentials injected via 1Password using `op run --env-file=tools/proxmox.env.tpl`
- Uses community.proxmox collection (proxmox_kvm module)
- Nodes: nodeA, nodeB, nodeD, nodeF on 10.10.10.x subnet
- Template VM ID: 999 (Ubuntu cloud-init template)
- Storage: cephVM for disks
- All VMs run as user d3

## Files Created
- ansible/playbooks/manage-vm.yml (scaffolded)

## Next Steps
Implement full task logic including error handling, idempotency verification,
and cloud-init wait logic after VM creation.
