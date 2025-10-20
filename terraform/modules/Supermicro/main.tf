resource "proxmox_virtual_environment_vm" "supermicro_cloud_composer" {
  name      = "supermicro-cloud-composer"
  node_name = var.virtual_environment_nodeC_name

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 16384
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

    user_data_file_id = proxmox_virtual_environment_file.supermicro_user_data_cloud_config.id
  }
    disk {
    datastore_id = "cephVM"
    # use file id passed in from root module (exposed by komodo module output)
    file_id   = var.debian_cloud_image_file_id
    interface = "virtio0"
    iothread  = true
    discard   = "on"
    size      = 50
  }
  network_device {
    bridge = "vmbr0"
    vlan_id = 10
  }

}
