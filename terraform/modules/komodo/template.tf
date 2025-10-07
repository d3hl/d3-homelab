#data "proxmox_virtual_environment_vms" "debian_template" {
#  tags = ["debian", "template"]
#}

resource "proxmox_virtual_environment_pool" "komodo-pool" {
  comment = "Managed by Terraform"
  pool_id = "komodo-pool"
}

resource "proxmox_virtual_environment_vm" "debian-template" {
  name      = "debian-template"
  node_name = var.virtual_environment_node1_name

  pool_id = proxmox_virtual_environment_pool.komodo-pool.pool_id  
  # should be true if qemu agent is not installed / enabled on the VM
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

    datastore_id = var.datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    //user_data_file_id = proxmox_virtual_environment_file.cloud_config.id       
  }
    disk {
    datastore_id = "cVM"
    file_id   = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface = "virtio0"
    iothread  = true
    discard   = "on"
    size      = 20
  }
  network_device {
    bridge = "vmbr0"
    vlan_id = 10
  }

}

resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "cephfs"
  node_name    = var.virtual_environment_node1_name
  #url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-nocloud-amd64.qcow2"
  url          =  "http://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}