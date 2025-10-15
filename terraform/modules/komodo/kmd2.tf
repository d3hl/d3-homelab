resource "proxmox_virtual_environment_file" "meta2_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_nodeA_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: kmd2
    EOF

    file_name = "meta2-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "kmd2" {
  name      = "kmd2"
  node_name = var.virtual_environment_nodeA_name
  pool_id = proxmox_virtual_environment_pool.komodo-pool.pool_id
  tags      = sort(["debian", "terraform", "komodo"])
#  migrate   = true
  clone {
    vm_id = proxmox_virtual_environment_vm.debian_template.id
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = 8192 
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    datastore_id = var.datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta2_data_cloud_config.id
  }
}
output "vm2_ipv4_address" {
  value = proxmox_virtual_environment_vm.kmd2.ipv4_addresses[1][0]
}