module "template" {
  source = "../../modules/template"
}

module "cloud_init" {
  source = "../../modules/cloud_init"
}
resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: ${var.hostname}
    EOF

    file_name = "meta-data-cloud-config-${var.hostname}.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "debian_vm" {
  name      = var.hostname
  node_name = var.virtual_environment_node_name
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
    user_data_file_id = module.cloud_init.user_data_cloud_config_id
    meta_data_file_id = module.meta.meta_data_file_id
  }
}

