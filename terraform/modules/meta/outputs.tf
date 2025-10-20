output "meta_data_cloud_config" {
  description = "The proxmox_virtual_environment_file resource for meta-data cloud-config"
  value       = proxmox_virtual_environment_file.meta_data_cloud_config
}

output "meta_data_file_id" {
  description = "The ID of the meta-data cloud-config file"
  value       = proxmox_virtual_environment_file.meta_data_cloud_config.id
}
