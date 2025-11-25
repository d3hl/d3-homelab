module "template" {
  source                        = "../../modules/template"
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_username  = var.virtual_environment_username
}
resource "proxmox_virtual_environment_pool" "komodo-pool" {
  pool_id = "komodo-pool"
}
# Create VM resources
resource "proxmox_virtual_environment_vm" "komodo" {
  count     = length(var.vm_names)
  name      = "kmd-${count.index}"
  node_name = var.virtual_environment_node_name
  tags      = sort(["debian", "terraform", "komodo"])

  clone {
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

    user_data_file_id = proxmox_virtual_environment_file.cloud_config[count.index].id
  }
}

output "vm_ipv4_addresses" {
  value = [for vm in proxmox_virtual_environment_vm.komodo : vm.ipv4_addresses[1][0]]
}
