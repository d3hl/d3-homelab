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

output "aap_urls" {
  description = "AAP service URLs for the all-in-one VM"
  value = {
    gateway    = "https://aap.${var.aap_dns_domain}"
    controller = "https://aap.${var.aap_dns_domain}"
    hub        = "https://aap.${var.aap_dns_domain}"
    eda        = "https://aap.${var.aap_dns_domain}"
  }
}

output "aap_components" {
  description = "AAP 2.6 components intended to run on the single VM"
  value = [
    "automation-gateway",
    "automation-controller",
    "automation-hub",
    "event-driven-ansible",
    "postgresql",
  ]
}

output "aap_ssh" {
  description = "SSH connection string"
  value       = "ssh d3@${split("/", var.aap_ip)[0]}"
}
