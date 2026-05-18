# AAP 2.6 Containerized All-In-One

This Terraform root module provisions one RHEL 10 VM for Red Hat Ansible Automation Platform 2.6 containerized in an all-in-one homelab layout.

Intended components on the single VM:

- automation gateway
- automation controller
- automation hub
- event-driven Ansible
- PostgreSQL

## Provision

Create a RHEL 10 cloud-init template in Proxmox first, then pass its VM ID.

```bash
cd terraform/aap
terraform init
terraform plan -var-file="../../secrets.tfvars" -var="rhel10_template_vm_id=<id>"
terraform apply -var-file="../../secrets.tfvars" -var="rhel10_template_vm_id=<id>"
```

Defaults:

- VM name: `aap`
- IP address: `10.10.10.60/24`
- FQDN: `aap.d3hl.site`
- Proxmox node: `nodeD`
- Template node: `nodeF`
- vCPU: `8`
- RAM: `24576` MiB
- Disk: `160` GiB on `cephVM`
- Cloud-init snippets: `cFS`

## Post-Provision

Render or create `ansible/inventory/aap.ini` from `ansible/inventory/aap.tpl`, then run:

```bash
cd ansible
ansible-playbook -i inventory/aap.ini playbooks/aap-prereqs.yml --ask-vault-pass
```

After that, run the Red Hat AAP 2.6 containerized installer bundle using the same inventory.
