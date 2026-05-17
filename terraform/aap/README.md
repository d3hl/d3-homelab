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

