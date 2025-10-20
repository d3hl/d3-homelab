output "debian_cloud_image_file_id" {
  description = "The file id of the downloaded Debian cloud image in the komodo module datastore (proxmox_virtual_environment_download_file.debian_cloud_image.id)"
  value       = proxmox_virtual_environment_download_file.debian_cloud_image.id
}
