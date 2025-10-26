module "template" {
  source                        = "../../modules/template-talos"
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_username  = var.virtual_environment_username
}

variable "control_nodes" {
  default = ["nodeA", "pve10"]
}

variable "worker_nodes" {
  default = ["nodeB", "nodeC", "nodeD"]
}

resource "proxmox_virtual_environment_pool" "Omni-pool" {
  pool_id = "talos-pool"
}

resource "proxmox_virtual_environment_vm" "control" {
  count     = length(var.control_nodes)
  name      = "omni-control-${count.index}"
  node_name = var.control_nodes[count.index]
  tags      = sort(["omni-controller", "terraform", "omni"])

  clone {
    vm_id = module.template.talos_template.vm_id

  }
  agent {
    enabled = true
  }


  cpu {
    type  = "x86-64-v2-AES"
    cores = 4
  }
  memory { dedicated = 4096 }

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

resource "proxmox_virtual_environment_vm" "worker" {
  count = length(var.worker_nodes)

  name      = "omni-worker-${count.index}"
  node_name = var.worker_nodes[count.index]
  tags      = sort(["omni-worker", "terraform", "omni"])

  clone {
    vm_id = module.template.talos_template.vm_id
  }
  agent {
    enabled = true
  }
  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }
  memory { dedicated = 2048 }
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

output "control_ipv4_addresses" {
  value = [for vm in proxmox_virtual_environment_vm.control : vm.ipv4_addresses[1][0]]
}

output "worker_ipv4_addresses" {
  value = [for vm in proxmox_virtual_environment_vm.worker : vm.ipv4_addresses[1][0]]
}

