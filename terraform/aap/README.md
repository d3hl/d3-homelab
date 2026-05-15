Terraform — terraform/aap/                                                                    
                                                                                                  
  ┌──────────────┬──────────────────────────────────────────────────────────────────────┐
  │     File     │                               Purpose                                │
  ├──────────────┼──────────────────────────────────────────────────────────────────────┤
  │ provider.tf  │ bpg/proxmox 0.104, Terraform Cloud workspace d3-org/homelab/aap      │
  ├──────────────┼──────────────────────────────────────────────────────────────────────┤
  │ variables.tf │ All inputs, including rhel9_template_vm_id (required, no default)    │
  ├──────────────┼──────────────────────────────────────────────────────────────────────┤
  │ vms.tf       │ 4 VMs: gateway, controller, hub, db — with static IPs via cloud-init │
  ├──────────────┼──────────────────────────────────────────────────────────────────────┤
  │ outputs.tf   │ VM IDs + assigned IPs                                                │
  └──────────────┴──────────────────────────────────────────────────────────────────────┘

  Assigned IPs (add to secrets.tfvars):
  rhel9_template_vm_id = <your RHEL 9 template ID>
  # All other vars are shared with the pve workspace:
  virtual_environment_endpoint  = "..."
  virtual_environment_api_token = "..."

  VM specs:

  ┌────────────────┬──────┬───────┬────────┬─────────────┐
  │       VM       │ vCPU │  RAM  │  Disk  │     IP      │
  ├────────────────┼──────┼───────┼────────┼─────────────┤
  │ aap-gateway    │ 2    │ 4 GB  │ 30 GB  │ 10.10.10.60 │
  ├────────────────┼──────┼───────┼────────┼─────────────┤
  │ aap-controller │ 4    │ 16 GB │ 60 GB  │ 10.10.10.61 │
  ├────────────────┼──────┼───────┼────────┼─────────────┤
  │ aap-hub        │ 4    │ 8 GB  │ 100 GB │ 10.10.10.62 │
  ├────────────────┼──────┼───────┼────────┼─────────────┤
  │ aap-db         │ 2    │ 8 GB  │ 40 GB  │ 10.10.10.63 │
  └────────────────┴──────┴───────┴────────┴─────────────┘

  Ansible — 3 files

  - ansible/inventory/aap.ini — Drop-in inventory for the AAP installer's ./setup.sh (fill in
  registry creds + passwords before use)
  - ansible/playbooks/aap-prereqs.yml — Runs before the AAP installer: RHSM registration, repo
  enablement, firewall rules, PostgreSQL setup with 3 databases and users
  - ansible/group_vars/aap.yml — DB password stubs (vault-encrypt these)

  ---
  Deployment order

  # 1. Prerequisites — create a RHEL 9 cloud-init template in Proxmox first
  #    (download RHEL 9 qcow2 from access.redhat.com, import, set VM ID)

  # 2. Provision VMs
  cd terraform/aap
  terraform init
  terraform apply -var-file="../../secrets.tfvars" -var="rhel9_template_vm_id=<id>"

  # 3. Pre-configure nodes
  cd ansible
  ansible-playbook -i inventory/aap.ini playbooks/aap-prereqs.yml \
    -e rhsm_username=<rhn-user> -e rhsm_password=<rhn-pass> \
    --ask-vault-pass

  # 4. Run AAP installer (download from access.redhat.com)
  tar xzf ansible-automation-platform-setup-bundle-*.tar.gz
  cd ansible-automation-platform-setup-bundle-*/
  ./setup.sh -i /path/to/ansible/inventory/aap.ini

  One prerequisite not automated: you need a RHEL 9 cloud-init template in Proxmox before step 2.
  Download the RHEL 9 KVM guest image from https://access.redhat.com, import it with qm
  importdisk, and note the VM ID for rhel9_template_vm_id.