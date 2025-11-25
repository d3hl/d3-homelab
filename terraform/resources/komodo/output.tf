output "vm_ipv4_address" {
  value = [for vm in proxmox_virtual_environment_vm.debian_vm : vm.ipv4_addresses[1][0]]
}