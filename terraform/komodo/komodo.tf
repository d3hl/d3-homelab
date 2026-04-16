resource "proxmox_virtual_environment_cloned_vm" "komodo" {
  for_each = var.komodo_node_map

  node_name = each.value
  name      = each.key

  clone = {
    source_vm_id = var.ubuntu_template_id
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = var.disk_size_gb
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = var.memory_mb
    balloon = var.memory_balloon_mb
  }

  cpu = {
    cores = var.cpu_cores
  }

}

output "komodo_vm_ids" {
  description = "Created Komodo VM IDs by name"
  value = {
    for vm_name, vm in proxmox_virtual_environment_cloned_vm.komodo :
    vm_name => vm.id
  }
}
