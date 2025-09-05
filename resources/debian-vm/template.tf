resource "proxmox_virtual_environment_vm" "debian-template" {
  name      = "debian-template"
  node_name = var.virtual_environment_node_name
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

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }
    disk {
    datastore_id = "cephfs"
    # qcow2 image downloaded from https://cloud.debian.org/images/cloud/bookworm/latest/ and renamed to *.img
    # the image is not of import type, so provider will use SSH client to import it
    file_id   = "cephfs:iso/debian-13-nocloud-amd64.img"
    interface = "virtio0"
    iothread  = true
    discard   = "on"
    size      = 20
  }
  network_device {
    bridge = "vmbr0"
  }

}

resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "cephfs"
  node_name    = "pve10"
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-nocloud-amd64.qcow2"
}