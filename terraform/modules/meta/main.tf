resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_nodeA_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: kmd1
    EOF

    file_name = "meta-data-cloud-config.yaml"
  }
}
