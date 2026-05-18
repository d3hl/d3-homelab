output "aap_vm_id" {
  description = "Proxmox VM ID for the AAP container-mode node"
  value       = proxmox_cloned_vm.aap.id
}

output "aap_ip" {
  description = "Static IP assigned to the AAP VM"
  value       = var.aap_ip
}

output "aap_fqdn" {
  description = "Internal FQDN for the AAP VM"
  value       = "aap.${var.aap_dns_domain}"
}

output "aap_ssh" {
  description = "SSH connection string"
  value       = "ssh d3@${split("/", var.aap_ip)[0]}"
}
