locals {
  ubuntu_image_url  = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
  ubuntu_image_name = "resolute-server-cloudimg-amd64.qcow2"
}

# Shared across all VMs in this workspace.
data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_file
}

# Download Ubuntu 24.04 LTS (Noble) cloud image to shared storage.
# content_type "import" lets Proxmox treat the file as a disk image for VM import.
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = var.import_datastore_id
  node_name    = var.virtual_environment_node_name
  url          = local.ubuntu_image_url
  file_name    = local.ubuntu_image_name
}

resource "proxmox_virtual_environment_file" "ubuntu_template_user_data" {
  content_type = "snippets"
  datastore_id = var.import_datastore_id
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

# Ubuntu 24.04 LTS base template — all workspace VMs clone from this.
# vm_id 999 matches the hardcoded clone source used across the project.
resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name        = "ubuntu-2604-template"
  description = "Ubuntu 26.04 LTS Noble — Terraform managed. Clone source for homelab VMs."
  tags        = ["ubuntu", "template", "resolute"]
  node_name   = var.virtual_environment_node_name
  vm_id       = var.ubuntu_template_vm_id

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

  # Required for OVMF; pre-enrolled keys let clones boot without manual key enrollment.
  efi_disk {
    datastore_id      = var.datastore_id
    type              = "4m"
    pre_enrolled_keys = true
  }

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
    prevent_destroy = true
  }
}

output "ubuntu_template_vm_id" {
  description = "VM ID of the Ubuntu template (used as clone source)"
  value       = proxmox_virtual_environment_vm.ubuntu_template.vm_id
}
