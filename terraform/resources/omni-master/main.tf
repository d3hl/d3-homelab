
module "template" {
  source = "../../modules/template-ubuntu"
}

resource "proxmox_virtual_environment_pool" "Talos-pool" {
  pool_id = "Talos-pool"
}
resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.filestore_id
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: ${var.hostname}
    EOF

    file_name = "meta-data-cloud-config-${var.hostname}.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = var.hostname
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

    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config.id
  }
}

