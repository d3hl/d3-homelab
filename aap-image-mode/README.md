# AAP Image Mode Homelab

This folder scopes a Red Hat Ansible Automation Platform homelab build around RHEL image mode.
The bootc image prepares the RHEL host baseline; the Red Hat AAP containerized installer still deploys the platform services after the VMs boot.

Context7 note: the requested `ctx7` lookup could not return usable output in this Windows shell because `npx`/PowerShell exited through the local command-not-found integration. The implementation below is based on current Red Hat documentation for AAP 2.6 containerized installation and RHEL 9 image mode.

## Scope

The homelab topology stays compact and Proxmox-friendly:

| Role | Host | IP | VM size |
|---|---|---:|---:|
| Platform gateway | `aap-gateway.homelab.local` | `10.10.10.60` | 4 vCPU / 16 GB / 60 GB |
| Controller + EDA | `aap-controller.homelab.local` | `10.10.10.61` | 4 vCPU / 32 GB / 80 GB |
| Private automation hub | `aap-hub.homelab.local` | `10.10.10.62` | 4 vCPU / 16 GB / 100 GB |
| Managed PostgreSQL | `aap-db.homelab.local` | `10.10.10.63` | 4 vCPU / 16 GB / 80 GB |

Defaults follow the repo assumptions: user `d3`, SSH key `/home/d3/.ssh/d3_tf.pub`, VM disks on `cephVM`, cloud-init snippets on `cFS`, and the `10.10.10.0/24` infrastructure network.

## Workflow

1. Build the RHEL bootc image from [image/Containerfile](image/Containerfile).
2. Convert it to QCOW2 with `bootc-image-builder` using [image/build-qcow2.example.sh](image/build-qcow2.example.sh).
3. Import the QCOW2 into Proxmox as a template using [image/proxmox-import.example.sh](image/proxmox-import.example.sh).
4. Clone the AAP VMs with the Terraform root in [terraform](terraform).
5. Run [ansible/playbooks/aap-host-preflight.yml](ansible/playbooks/aap-host-preflight.yml) to verify hostnames, services, `/etc/hosts`, and firewalld.
6. Download the AAP containerized installer from Red Hat and run it with [ansible/inventory/aap-installer.ini.example](ansible/inventory/aap-installer.ini.example).

## Red Hat References

- AAP 2.6 containerized install requires a valid AAP subscription, a valid RHEL subscription, RHEL 9.4+ or RHEL 10, and per-VM minimums of 16 GB RAM, 4 CPUs, and 60 GB disk.
- AAP online inventory requires `registry_username` and `registry_password`; disconnected/bundled installs use `bundle_install=true` and `bundle_dir` instead.
- RHEL image mode uses `registry.redhat.io/rhel9/rhel-bootc` as the bootc base image and can be converted to QCOW2 with `registry.redhat.io/rhel9/bootc-image-builder`.

Useful docs:

- https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/install-ref_cont_aap_system_requirements
- https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/install-ref_configuring_inventory_file
- https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/deploying-the-rhel-bootc-images_using-image-mode-for-rhel-to-build-deploy-and-manage-operating-systems
- https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/building-and-testing-the-rhel-bootable-container-images_using-image-mode-for-rhel-to-build-deploy-and-manage-operating-systems

