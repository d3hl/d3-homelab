resource "proxmox_virtual_environment_vm" "komodo2" {
  name      = "komodo2"
  node_name = var.virtual_environment_node2_name
  tags      = sort(["debian", "terraform","komodo"])
  vm_id     = 201
  # should be true if qemu agent is not installed / enabled on the VM
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
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
  node_name    = "pve11"
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-nocloud-amd64.qcow2"
}