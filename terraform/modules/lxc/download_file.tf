resource "proxmox_virtual_environment_download_file" "latest_debian_12_bookworm_qcow2_img" {
  content_type        = "import"
  datastore_id        = "cFS"
  file_name           = "debian-12-generic-amd64.qcow2"
  node_name           = var.virtual_environment_pve10_name
  url                 = var.latest_debian_12_bookworm_qcow2_img_url
  overwrite           = true
  overwrite_unmanaged = true
}