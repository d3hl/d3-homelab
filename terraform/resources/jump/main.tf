module "template" {
  source                        = "../../modules/template-ubuntu"
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_username  = var.virtual_environment_username
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = "jump"
  node_name = var.virtual_environment_node_name
  tags      = sort(["ubuntu", "terraform"])

  clone {
    vm_id = module.template.ubuntu_template.vm_id

  }
  agent {
    enabled = true
  }
  memory {
    dedicated = 8192
  }
  disk {
    datastore_id = "cephVM"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
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
