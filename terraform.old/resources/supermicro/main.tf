module "template" {
  source                        = "../../modules/template-ubuntu"
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_username  = var.virtual_environment_username
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = "supermicro"
  node_name = var.virtual_environment_node_name
  tags      = sort(["ubuntu", "terraform"])

  clone {
    vm_id = module.template.ubuntu_template.vm_id

  }
  agent {
    enabled = true
  }
  cpu {
    type  = "x86-64-v2-AES"
    cores = 16
  }
  memory {
    dedicated = 32768
  }
  disk {
    datastore_id = "cephVM"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 300
  }
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }
}
output "master_ipv4_address" {
  value = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses[1][0]
}
