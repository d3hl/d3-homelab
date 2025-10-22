output "ubuntu_template" {
  value = {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.id
  }
}
