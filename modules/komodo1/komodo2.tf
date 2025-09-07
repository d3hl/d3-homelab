resource "proxmox_virtual_environment_file" "meta2_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "cephfs"
  node_name    = var.virtual_environment_node2_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: komodo2
    EOF

    file_name = "meta-data-cloud-config.yaml"
  }
}
resource "proxmox_virtual_environment_vm" "komodo2" {
  name      = "komodo2"
  node_name = var.virtual_environment_node2_name
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

    datastore_id = var.datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta2_data_file_id = proxmox_virtual_environment_file.meta2_data_cloud_config.id
  }
}

output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.komodo2.ipv4_addresses[1][0]
}