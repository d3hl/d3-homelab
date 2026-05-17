# AAP Image Mode Terraform

This Terraform root provisions the Red Hat Ansible Automation Platform image-mode VMs for the homelab. It expects a RHEL 10 bootc Proxmox template to already exist, then clones four AAP nodes from it.

## Workspace

- HCP Terraform organization: `d3-org`
- HCP Terraform project: `homelab`
- HCP Terraform workspace: `aap-image-mode`
- Provider: `bpg/proxmox` `~> 0.104`

## Homelab Defaults

| Setting | Default |
|---|---|
| Proxmox API endpoint | `var.virtual_environment_endpoint` |
| Proxmox API token | `var.virtual_environment_api_token` |
| SSH user | `d3` |
| Default VM node | `nodeD` |
| RHEL bootc template node | `nodeF` |
| RHEL bootc template VM ID | `9906` |
| VM datastore | `cephVM` |
| Network bridge | `vmbr0` |
| Gateway | `10.10.10.1` |
| DNS domain | `d3hl.site` |

## VM Layout

| Key | VM name | FQDN | IP | Size |
|---|---|---|---:|---:|
| `gateway` | `aap-gateway` | `aap-gateway.d3hl.site` | `10.10.10.60/24` | 4 vCPU / 16 GB / 60 GB |
| `controller` | `aap-controller` | `aap-controller.d3hl.site` | `10.10.10.61/24` | 4 vCPU / 32 GB / 80 GB |
| `hub` | `aap-hub` | `aap-hub.d3hl.site` | `10.10.10.62/24` | 4 vCPU / 16 GB / 100 GB |
| `db` | `aap-db` | `aap-db.d3hl.site` | `10.10.10.63/24` | 4 vCPU / 16 GB / 80 GB |

All VMs are tagged with `rhel10`, `bootc`, `aap`, and their role. They are placed in the Proxmox pool `aap-image-mode`.

## Prerequisite

Build and import the RHEL 10 bootc template first from the repo-level image-mode workflow:

```bash
cd aap-image-mode
cp image/bootc-image-builder.config.toml.example image/bootc-image-builder.config.toml
# Add /home/d3/.ssh/d3_tf.pub content to image/bootc-image-builder.config.toml
./image/build-qcow2.example.sh
./image/proxmox-import.example.sh
```

The import script defaults to VM ID `9906`, matching `var.rhel_bootc_template_vm_id`.

## Run

From this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan -var-file="../../secrets.tfvars"
terraform apply -var-file="../../secrets.tfvars"
```

Required sensitive values are expected to come from `../../secrets.tfvars` or HCP Terraform workspace variables:

```hcl
virtual_environment_endpoint  = "https://10.10.10.10:8006/"
virtual_environment_api_token = "terraform@pve!provider=REPLACE_WITH_TOKEN_SECRET"
```

Override `aap_nodes` if you need to change sizing, IPs, target nodes, or per-node template IDs.

## Outputs

- `aap_image_mode_vm_ids`
- `aap_image_mode_fqdns`
- `aap_image_mode_ips`

After Terraform finishes, continue with the Ansible preflight and Red Hat AAP containerized installer inventory under `aap-image-mode/ansible`.

######
# AAP Image Mode Homelab

This folder scopes a Red Hat Ansible Automation Platform homelab build around RHEL 10 image mode.
The bootc image prepares the RHEL host baseline; the Red Hat AAP containerized installer still deploys the platform services after the VMs boot.

Context7 note: the requested `ctx7` lookup could not return usable output in this Windows shell because `npx`/PowerShell exited through the local command-not-found integration. The implementation below is based on current Red Hat documentation for AAP 2.6 containerized installation and RHEL 9 image mode.

## Scope

The homelab topology stays compact and Proxmox-friendly:

| Role | Host | IP | VM size |
|---|---|---:|---:|
| Platform gateway | `aap-gateway.d3hl.site` | `10.10.10.60` | 4 vCPU / 16 GB / 60 GB |
| Controller + EDA | `aap-controller.d3hl.site` | `10.10.10.61` | 4 vCPU / 32 GB / 80 GB |
| Private automation hub | `aap-hub.d3hl.site` | `10.10.10.62` | 4 vCPU / 16 GB / 100 GB |
| Managed PostgreSQL | `aap-db.d3hl.site` | `10.10.10.63` | 4 vCPU / 16 GB / 80 GB |

Defaults follow the repo assumptions: user `d3`, SSH key `/home/d3/.ssh/d3_tf.pub`, VM disks on `cephVM`, cloud-init snippets on `cFS`, and the `10.10.10.0/24` infrastructure network.

## Workflow

1. Build the RHEL bootc image from [image/Containerfile](image/Containerfile).
2. Convert it to QCOW2 with `bootc-image-builder` using [image/build-qcow2.example.sh](image/build-qcow2.example.sh).
3. Import the QCOW2 into Proxmox as a template using [image/proxmox-import.example.sh](image/proxmox-import.example.sh).
4. Clone the AAP VMs with the Terraform root in [terraform/aap](../terraform/aap).
5. Run [ansible/playbooks/aap-host-preflight.yml](ansible/playbooks/aap-host-preflight.yml) to verify hostnames, services, `/etc/hosts`, and firewalld.
6. Download the AAP containerized installer from Red Hat and run it with [ansible/inventory/aap-installer.ini.example](ansible/inventory/aap-installer.ini.example).

## Red Hat References

- AAP 2.6 containerized install requires a valid AAP subscription, a valid RHEL subscription, RHEL 9.4+ or RHEL 10, and per-VM minimums of 16 GB RAM, 4 CPUs, and 60 GB disk. This homelab scope targets RHEL 10.
- AAP online inventory requires `registry_username` and `registry_password`; disconnected/bundled installs use `bundle_install=true` and `bundle_dir` instead.
- RHEL image mode uses `registry.redhat.io/rhel10/rhel-bootc` as the bootc base image and can be converted to QCOW2 with `registry.redhat.io/rhel10/bootc-image-builder`.

Useful docs:

- https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/install-ref_cont_aap_system_requirements
- https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/install-ref_configuring_inventory_file
- https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/deploying-the-rhel-bootc-images_using-image-mode-for-rhel-to-build-deploy-and-manage-operating-systems
- https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/building-and-testing-the-rhel-bootable-container-images_using-image-mode-for-rhel-to-build-deploy-and-manage-operating-systems
