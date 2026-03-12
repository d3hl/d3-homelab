resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name
  url          = "http://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}
output "debian_cloud_image_file_id" {
  description = "The file id of the downloaded Debian cloud image in the komodo module datastore (proxmox_virtual_environment_download_file.debian_cloud_image.id)"
  value       = proxmox_virtual_environment_download_file.debian_cloud_image.id
}
output "ubuntu_cloud_image_file_id" {
  description = "The file id of the downloaded Ubuntu cloud image in the komodo module datastore (proxmox_virtual_environment_download_file.ubuntu_cloud_image.id)"
  value       = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}
