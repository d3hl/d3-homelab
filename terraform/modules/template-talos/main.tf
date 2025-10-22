resource "proxmox_virtual_environment_vm" "talos_template" {
  name      = "talos-template"
  node_name = var.virtual_environment_node_name


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
  cdrom {
    file_id = data.proxmox_virtual_environment_file.talos_nocloud_image.id
  }
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

  }
  disk {
    datastore_id = "cephVM"
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
data "proxmox_virtual_environment_file" "talos_nocloud_image" {
  content_type = "iso"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name
  file_name    = "metal-amd64-omni-omni-v1.11.3.iso"
}
output "talos_template" {
  value = {
    vm_id = proxmox_virtual_environment_vm.talos_template.id
  }
}
