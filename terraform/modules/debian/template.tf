resource "proxmox_virtual_environment_vm" "debian_template" {
  name      = "debian-template"
  node_name = var.virtual_environment_node_name

  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = 2
    type  = "x86-64-v2-AES" # recommended for modern CPUs
  }

  memory {
    dedicated = 2048
  }

  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = "cephVM"
    file_id      = proxmox_virtual_environment_download_file.debian_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 40
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }
}

#resource "proxmox_virtual_environment_file" "debian_image" {
resource "proxmox_virtual_environment_download_file" "debian_image" {
  content_type = "import"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name    = "debian-13-genericcloud-amd64.qcow2"
}