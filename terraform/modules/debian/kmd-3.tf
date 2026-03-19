resource "proxmox_virtual_environment_cloned_vm" "debian_clone" {
  node_name = var.virtual_environment_node_name
  name      = "kmd-2"

  clone = {
    source_vm_id = proxmox_virtual_environment_vm.debian_template.vm_id
    full         = true
  }
  # Manage disks by slot
  disk = {
    # Resize the boot disk inherited from template
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 100 # Expand from 20GB to 50GB
      discard      = "on"
      iothread     = true
      ssd          = true
    }
  }
  # Only explicitly listed devices are managed
  # Network device inherited from template is preserved but not managed
  # To manage it, explicitly list it here:
  # Only manage the first network interface
  network = {
    net0 = {
      bridge = "vmbr0"
      model  = "virtio"
      tag    = 10 # Add VLAN tag to net0
    }
  }

  # Memory configuration using new terminology
  memory = {
    size    = 16384 # Total memory available to VM
    balloon = 512   # Minimum guaranteed memory via balloon device
  }

  cpu = {
    cores = 4
  }

}

output "vm_id" {
  value = proxmox_virtual_environment_cloned_vm.debian_clone.id
}