module "template" {
  source = "/../modules/template"
}
module "meta" {
  source = "/../modules/meta"
}
resource "proxmox_virtual_environment_vm" "kmd1" {
  name      = "kmd1"
  node_name = var.virtual_environment_nodeA_name
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
    user_data_file_id = module.cloud_init.user_data_file_id
    meta_data_file_id = module.meta.meta_data_file_id
  }
}

