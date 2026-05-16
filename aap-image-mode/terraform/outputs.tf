output "aap_image_mode_vm_ids" {
  description = "Proxmox VM IDs for the AAP image-mode nodes"
  value       = { for name, vm in proxmox_cloned_vm.aap : name => vm.id }
}

output "aap_image_mode_fqdns" {
  description = "Internal FQDNs for the AAP image-mode nodes"
  value       = { for name, short in local.aap_vm_names : name => "${short}.${var.aap_dns_domain}" }
}

output "aap_image_mode_ips" {
  description = "Static IPs assigned to the AAP image-mode nodes"
  value       = { for name, node in var.aap_nodes : name => node.ip }
}

