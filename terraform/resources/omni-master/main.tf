
module "template" {
  source                        = "../../modules/template-ubuntu"
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_username  = var.virtual_environment_username
}

resource "proxmox_virtual_environment_pool" "Talos-pool" {
  pool_id = "Talos-pool"
}
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = "omni-${count.index}"
  node_name = var.virtual_environment_node_name
  tags      = sort(["ubuntu", "terraform", "omni"])

  clone {
    vm_id = module.template.ubuntu_template.vm_id

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

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config[count.index].id
  }
}

