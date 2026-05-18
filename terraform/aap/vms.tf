resource "proxmox_virtual_environment_pool" "aap" {
  pool_id = "aap"
  comment = "Ansible Automation Platform 2.6 containerized all-in-one"
}

resource "proxmox_cloned_vm" "aap" {
  node_name       = var.virtual_environment_node_name
  name            = "aap"
  tags            = ["rhel10", "aap26", "container", "all-in-one"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel10_template_vm_id
    source_node_name = var.rhel10_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap.id
  }

  cpu = {
    cores = var.aap_cores
    type  = "host"
  }

  memory = {
    size = var.aap_memory
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = var.aap_disk_size
      discard      = "on"
      iothread     = true
    }
  }

  network = {
    net0 = {
      bridge = var.network_bridge
      model  = "virtio"
      tag    = var.network_vlan_tag
    }
  }

}
