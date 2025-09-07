resource "proxmox_virtual_environment_vm" "komodo1" {
  name      = "komodo1"
  node_name = var.virtual_environment_node_name

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
    dns {
      servers = ["1.1.1.1"]
    }
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