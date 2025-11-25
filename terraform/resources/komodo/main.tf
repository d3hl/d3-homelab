module "template" {
  source                        = "../../modules/template"
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_username  = var.virtual_environment_username
}

module "cloud_init" {
  source = "../../modules/cloud-init"
}




resource "proxmox_virtual_environment_pool" "komodo-pool" {
  pool_id = "komodo-pool"
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  count        = length(var.vm_names)
  content_type = "snippets"
  datastore_id = var.filestore_id
  node_name    = var.node_names[count.index]

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: kmd-${count.index}
    EOF

    file_name = "meta-data-cloud-config-kmd-${count.index}.yaml"
  }
}

# Create VM resources
resource "proxmox_virtual_environment_vm" "debian_vm" {
  count     = length(var.vm_names)
  name      = "kmd-${count.index}"
  node_name = var.node_names[count.index]
  tags      = sort(["debian", "terraform", "komodo"])

  clone {
    vm_id = module.template.debian_template

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

    user_data_file_id = module.cloud_init.user_data_cloud_config_id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config[count.index].id
  }
}

