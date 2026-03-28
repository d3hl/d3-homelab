resource "proxmox_virtual_environment_cloned_vm" "kmd-2" {
  node_name = var.virtual_environment_node_pve10
  name      = "kmd-2"

  clone = {
    source_vm_id = var.ubuntu_template
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

  # Memory configuration using new terminology
  memory = {
    size    = 16384 # Total memory available to VM
    balloon = 8192  # Minimum guaranteed memory via balloon device
  }

  cpu = {
    cores = 4
  }

}

output "vm_id" {
  value = proxmox_virtual_environment_cloned_vm.kmd-2.id
}