data "proxmox_virtual_environment_pool" "komodo_pool" {
  poolid = "komodo"
}
output "komodo_pool" {
  description = "The Komodo Pool data source"
  value       = data.proxmox_virtual_environment_pool.komodo_pool
}