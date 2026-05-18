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

## GitHub Actions

The workflow `.github/workflows/hcp-terraform-aap.yml` uploads this root module to the HCP Terraform workspace `aap-container`.

Required setup:

- Register an online GitHub self-hosted runner for this repository with the default `self-hosted` label.
- Add the repository secret `TF_API_TOKEN` with permission to upload configuration versions, create runs, and apply runs in HCP Terraform.
- Configure workspace variables in HCP Terraform for `virtual_environment_endpoint`, `virtual_environment_api_token`, and any non-default inputs.
- Make sure the `aap-container` workspace execution environment can reach the Proxmox API and SSH endpoints on the homelab network.
- Make sure the run environment has access to `/home/d3/.ssh/d3_tf.pub`, or change `vms.tf` to source the cloud-init public key from an HCP Terraform variable.

Trigger behavior:

- Pull requests touching `terraform/aap/**` create a speculative plan and comment the summary on the PR.
- Pushes to `main` touching `terraform/aap/**` create and apply a run.
- Manual `workflow_dispatch` creates and applies a run.

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

Use an ignored local copy of the AAP growth inventory for installer secrets:

```bash
cd ansible
cp inventory/inventory-growth.ini inventory/inventory-growth.local.ini
```

Populate `inventory/inventory-growth.local.ini` from Ansible Vault, 1Password, or another local secret source. Do not commit the local inventory.

After the VM is provisioned and the Red Hat AAP 2.6 containerized installer bundle is available on the AAP host, run the installer from the extracted installer directory:

```bash
ansible-playbook -i inventory-growth.local.ini ansible.containerized_installer.install
```

For the deployment checklist and preflight helper, see `docs/aap-deployment-test-plan.md`.
