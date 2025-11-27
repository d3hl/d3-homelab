
resource "proxmox_virtual_environment_vm" "debian_template" {
  name      = "debian-template"
  node_name = var.virtual_environment_node_name


  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"
  cpu {
    #type  = "host"
    type  = "x86-64-v2-AES" # recommended for modern CPUs
    cores = 2
  }

  memory {
    dedicated = 2048
  }
  serial_device {
    device = "socket"
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
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

  }
  disk {
    datastore_id = "cephVM"
    import_from  = proxmox_virtual_environment_download_file.debian_image.id
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
#resource "proxmox_virtual_environment_file" "debian_image" {
resource "proxmox_virtual_environment_download_file" "debian_image" {
  content_type = "import"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-13-generic-amd64.qcow2"
  file_name    = "debian-13-generic-amd64.qcow2"
}