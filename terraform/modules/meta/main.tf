resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.virtual_environment_nodeA_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: ${var.hostname}
    EOF

    file_name = "meta-data-cloud-config-${var.hostname}.yaml"
  }
}
