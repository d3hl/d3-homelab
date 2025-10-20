data "proxmox_virtual_environment_vm" "debian_template" {
  node_name = var.virtual_environment_nodeA_name
  vm_id     = module.template.debian_template.vm_id
}
resource "proxmox_virtual_environment_vm" "kmd1" {
  name      = "kmd1"
  node_name = var.virtual_environment_nodeA_name
  pool_id   = module.pools.komodo_pool_id
  tags      = sort(["debian", "terraform", "komodo"])

  clone {
    #    vm_id = data.proxmox_virtual_environment_vm.debian_template.vm_id
    vm_id = module.template.debian_template.vm_id
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = 16384
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    datastore_id      = var.datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = module.meta.meta_data_cloud_config.id
  }
}

