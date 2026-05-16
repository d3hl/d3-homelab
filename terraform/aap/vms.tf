resource "proxmox_virtual_environment_pool" "aap_pool" {
  pool_id = "aap-pool"
  comment = "Ansible Automation Platform VMs"
}

# aap-gateway — 2 vCPU / 4 GB / 30 GB @ 10.10.10.60
resource "proxmox_cloned_vm" "aap_gateway" {
  node_name       = var.virtual_environment_node_name
  name            = "aap-gateway"
  tags            = ["rhel9", "aap", "gateway"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel9_template_vm_id
    source_node_name = var.rhel9_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_pool.id
  }

  cpu = {
    cores = 2
    type  = "host"
  }

  memory = {
    size = 4096
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = 30
      discard      = "on"
      iothread     = true
    }
  }
}

# aap-controller — 4 vCPU / 16 GB / 60 GB @ 10.10.10.61
resource "proxmox_cloned_vm" "aap_controller" {
  node_name       = var.virtual_environment_node_name
  name            = "aap-controller"
  tags            = ["rhel9", "aap", "controller"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel9_template_vm_id
    source_node_name = var.rhel9_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_pool.id
  }

  cpu = {
    cores = 4
    type  = "host"
  }

  memory = {
    size = 16384
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = 60
      discard      = "on"
      iothread     = true
    }
  }
}

# aap-hub — 4 vCPU / 8 GB / 100 GB @ 10.10.10.62
resource "proxmox_cloned_vm" "aap_hub" {
  node_name       = var.virtual_environment_node_name
  name            = "aap-hub"
  tags            = ["rhel9", "aap", "hub"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel9_template_vm_id
    source_node_name = var.rhel9_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_pool.id
  }

  cpu = {
    cores = 4
    type  = "host"
  }

  memory = {
    size = 8192
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = 100
      discard      = "on"
      iothread     = true
    }
  }
}

# aap-db — 2 vCPU / 8 GB / 40 GB @ 10.10.10.63
resource "proxmox_cloned_vm" "aap_db" {
  node_name       = var.virtual_environment_node_name
  name            = "aap-db"
  tags            = ["rhel9", "aap", "database"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel9_template_vm_id
    source_node_name = var.rhel9_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_pool.id
  }

  cpu = {
    cores = 2
    type  = "host"
  }

  memory = {
    size = 8192
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = 40
      discard      = "on"
      iothread     = true
    }
  }
}
