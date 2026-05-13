output "aap_vm_id" {
  description = "Proxmox VM ID for the AAP server"
  value       = proxmox_virtual_environment_vm.aap_server.vm_id
}

output "aap_vm_name" {
  description = "Proxmox VM name"
  value       = proxmox_virtual_environment_vm.aap_server.name
}

output "aap_node" {
  description = "Proxmox node hosting the AAP server"
  value       = proxmox_virtual_environment_vm.aap_server.node_name
}
