resource "proxmox_virtual_environment_file" "meta3_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "cephfs"
  node_name    = var.virtual_environment_node3_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: komodo3
    EOF

    file_name = "meta3-data-cloud-config.yaml"
  }
}


resource "proxmox_virtual_environment_vm" "komodo3" {
  name      = "komodo3"
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

    datastore_id = var.datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta3_data_cloud_config.id
  }
}
output "vm3_ipv4_address" {
  value = proxmox_virtual_environment_vm.komodo3.ipv4_addresses[1][0]
}