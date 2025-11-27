module "template" {
  source                        = "../../modules/template"
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_username  = var.virtual_environment_username
}
resource "proxmox_virtual_environment_pool" "komodo-pool" {
  pool_id = "komodo-pool"
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  count        = length(var.vm_names)
  content_type = "snippets"
  datastore_id = var.filestore_id
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: kmd-${count.index}
    EOF

    file_name = "meta-data-kmd-${count.index}.yaml"
  }
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
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config[count.index].id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

  }
}

output "vm_ipv4_addresses" {
  value = [for vm in proxmox_virtual_environment_vm.komodo : vm.ipv4_addresses[1][0]]
}
