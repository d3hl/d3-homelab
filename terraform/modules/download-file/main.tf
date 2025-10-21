terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.1" # x-release-please-version
    }
  }

}
resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_nodeA_name
  #url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-nocloud-amd64.qcow2"
  url = "http://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}
output "debian_cloud_image_file_id" {
  description = "The file id of the downloaded Debian cloud image in the komodo module datastore (proxmox_virtual_environment_download_file.debian_cloud_image.id)"
  value       = proxmox_virtual_environment_download_file.debian_cloud_image.id
}
