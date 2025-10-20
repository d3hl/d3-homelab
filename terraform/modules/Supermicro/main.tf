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

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }
    disk {
    datastore_id = "cephVM"
    file_id   = proxmox_virtual_environment_download_file.debian_cloud_image.id
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

resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_nodeA_name
  #url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-nocloud-amd64.qcow2"
  url          =  "http://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}