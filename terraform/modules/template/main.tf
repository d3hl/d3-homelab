terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.1" # x-release-please-version
    }
  }

}
resource "proxmox_virtual_environment_vm" "debian_template" {
  name      = "debian-template"
  node_name = var.virtual_environment_nodeA_name


  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m"
  }

  #  hostpci {
  #    device = "hostpci0"
  #    mapping     = "hostpci0"
  #    pcie   = true
  #  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = module.cloud-init.user_data_cloud_config.id
  }
  disk {
    datastore_id = "cephVM"
    file_id      = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
  network_device {
    bridge  = "vmbr0"
    vlan_id = 10
  }

}
output "vm_debian_template" {
  description = "The ID of the Debian VM template"
  value       = proxmox_virtual_environment_vm.debian_template.id

}