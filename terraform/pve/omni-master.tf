resource "proxmox_cloned_vm" "omni_master" {
  node_name       = var.virtual_environment_node_nodeB
  name            = "omni-master"
  tags            = ["ubuntu", "omni"]
  stop_on_destroy = true

  clone = {
    source_vm_id = 9999
    node_name    = "nodeF"
    full         = true
  }

  # Map-based network devices
  network = {
    net0 = {
      bridge = "vmbr0"
      model  = "virtio"
      tag    = 10
    }
    net1 = {
      bridge = "vmbr0"
      model  = "virtio"
      tag    = 11
    }
  }
}

output "omni_master_vm_id" {
  description = "Proxmox VM ID of omni-master"
  value       = proxmox_cloned_vm.omni_master.id
}
