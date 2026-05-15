output "aap_vm_ids" {
  description = "Proxmox VM IDs for all AAP components"
  value = {
    gateway    = proxmox_cloned_vm.aap_gateway.id
    controller = proxmox_cloned_vm.aap_controller.id
    hub        = proxmox_cloned_vm.aap_hub.id
    db         = proxmox_cloned_vm.aap_db.id
  }
}

output "aap_ips" {
  description = "Static IPs assigned to AAP VMs"
  value = {
    gateway    = var.aap_gateway_ip
    controller = var.aap_controller_ip
    hub        = var.aap_hub_ip
    db         = var.aap_db_ip
  }
}

output "aap_pool_id" {
  description = "Proxmox resource pool for AAP VMs"
  value       = proxmox_virtual_environment_pool.aap_pool.id
}
