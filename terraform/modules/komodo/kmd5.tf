resource "proxmox_virtual_environment_file" "meta5_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "cephfs"
  node_name    = var.virtual_environment_nodeA_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: kmd5
    EOF

    file_name = "meta5-data-cloud-config.yaml"
  }
}


resource "proxmox_virtual_environment_vm" "kmd5" {
  name      = "kmd5"
  node_name = var.virtual_environment_pve14_name
  pool_id = proxmox_virtual_environment_pool.komodo-pool.pool_id
  tags      = sort(["debian", "terraform", "komodo"])
  #migrate   = true
  clone {
    vm_id = proxmox_virtual_environment_vm.debian-template.id
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
    meta_data_file_id = proxmox_virtual_environment_file.meta5_data_cloud_config.id
  }
}
output "vm5_ipv4_address" {
  value = proxmox_virtual_environment_vm.kmd5.ipv4_addresses[1][0]
}