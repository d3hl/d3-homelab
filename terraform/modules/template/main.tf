
###########################
resource "proxmox_virtual_environment_vm" "debian_template" {
  name      = "debian-template"
  node_name = var.virtual_environment_node_name


  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    type  = "host"
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

  }
  disk {
    datastore_id = "cephVM"
    file_id      = data.proxmox_virtual_environment_file.debian_image.id
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
data "proxmox_virtual_environment_file" "debian_image" {
  content_type = "import"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name
  file_name    = "debian-12-genericcloud-amd64.qcow2"
}
output "debian_template" {
  description = "The ID of the Debian VM template"
  value = {
    vm_id = proxmox_virtual_environment_vm.debian_template.id
  }
}

