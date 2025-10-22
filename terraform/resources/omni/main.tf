module "template" {
  source                        = "../../modules/template-talos"
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_username  = var.virtual_environment_username
}

resource "proxmox_virtual_environment_pool" "Omni-pool" {
  pool_id = "Omni-pool"
}
resource "proxmox_virtual_environment_vm" "omni_control" {
  count     = 2
  name      = "omni-control-${count.index}"
  node_name = nodeA
  tags      = sort(["omni-controller", "terraform", "omni"])

  clone {
    vm_id = module.template.talos_template.vm_id

  }
  cpu {
    cores = 4
  }


  agent {
    enabled = true
  }

  memory {
    dedicated = 4096
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  disk {
    datastore_id = "cephVM"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 100
  }
}
resource "proxmox_virtual_environment_vm" "omni_worker" {
  count     = 2
  name      = "omni-worker-${count.index}"
  node_name = nodeB
  tags      = sort(["omni-worker", "terraform", "omni"])

  clone {
    vm_id = module.template.talos_template.vm_id

  }
  cpu {
    cores = 2
  }


  agent {
    enabled = true
  }

  memory {
    dedicated = 2048
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  disk {
    datastore_id = "cephVM"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 100
  }
}
