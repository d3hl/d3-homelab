data "proxmox_virtual_environment_vm" "debian_template" {
  depends_on = [proxmox_virtual_environment_vm.debian_template]
  vm_id      = proxmox_virtual_environment_vm.debian_template.vm_id
  node_name  = data.proxmox_virtual_environment_nodes.nodeA.names[0]
}


output "proxmox_virtual_environment_vm.debian_template" {
    value       = proxmox_virtual_environment_vm.debian_template.vms
    description = "The IPv4 address of the kmd1 VM."
  }
