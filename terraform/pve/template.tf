locals {
  ubuntu_image_url  = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  ubuntu_image_name = "noble-server-cloudimg-amd64.qcow2"
}

# Download Ubuntu 24.04 LTS (Noble) cloud image to shared storage.
# content_type "import" tells Proxmox to treat the file as a disk image for direct VM import.
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = var.snippets_datastore_id
  node_name    = var.virtual_environment_node_name
  url          = local.ubuntu_image_url
  file_name    = local.ubuntu_image_name
}

# Cloud-init user-data snippet uploaded to cFS (shared across all Proxmox nodes).
resource "proxmox_virtual_environment_file" "ubuntu_template_user_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ubuntu-template
    timezone: Asia/Singapore
    users:
      - default
      - name: d3
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
    EOF

    file_name = "ubuntu-template-user-data.yaml"
  }
}

# Ubuntu 24.04 LTS template VM — cloned by all other pve-workspace VMs.
# vm_id 999 is hardcoded to match the clone source referenced across the project.
resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name        = "ubuntu-2404-template"
  description = "Ubuntu 24.04 LTS Noble — managed by Terraform. Clone source for homelab VMs."
  tags        = ["ubuntu", "template", "noble"]
  node_name   = var.virtual_environment_node_name
  vm_id       = 999

  template = true
  started  = false

  machine = "q35"
  bios    = "ovmf"

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  # EFI vars disk — required for OVMF. Pre-enroll keys so clones boot without manual key enrollment.
  efi_disk {
    datastore_id      = var.datastore_id
    type              = "4m"
    pre_enrolled_keys = true
  }

  # Boot disk imported from the Ubuntu cloud image.
  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.ubuntu_template_user_data.id
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  lifecycle {
    # Prevent accidental re-creation; template changes should be intentional.
    prevent_destroy = true
  }
}

output "ubuntu_template_vm_id" {
  description = "VM ID of the Ubuntu template (used as clone source)"
  value       = proxmox_virtual_environment_vm.ubuntu_template.vm_id
}
