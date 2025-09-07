resource "proxmox_virtual_environment_vm" "komodo1" {
  name      = "komodo1"
  node_name = var.virtual_environment_node1_name
  tags      = sort(["debian", "terraform","komodo"])

  clone {
    vm_id = proxmox_virtual_environment_vm.debian-template.id
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = 4096
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

#output "vm_ipv4_address" {
  #value = proxmox_virtual_environment_vm.komodo1.ipv4_addresses[0]
#}