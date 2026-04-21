module "talos_omni" {
  source = "./modules/talos-omni"

  # Proxmox API credentials
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_username  = var.virtual_environment_username
  virtual_environment_insecure  = var.virtual_environment_insecure

  # Cluster configuration
  cluster_name        = var.cluster_name
  talos_version       = var.talos_version
  control_plane_count = var.control_plane_count
  worker_count        = var.worker_count

  # Infrastructure
  proxmox_nodes = var.proxmox_nodes
  datastore_id  = var.datastore_id

  # Node resources
  cpu_cores    = var.cpu_cores
  memory_mb    = var.memory_mb
  disk_size_gb = var.disk_size_gb

  # SSH configuration
  ssh_public_key_path = var.ssh_public_key_path

  # Omni controller
  omni_controller_enabled                = var.omni_controller_enabled
  omni_controller_name                   = var.omni_controller_name
  omni_controller_ip                     = var.omni_controller_ip
  omni_controller_cpu_cores              = var.omni_controller_cpu_cores
  omni_controller_memory_mb              = var.omni_controller_memory_mb
  omni_controller_disk_size_gb           = var.omni_controller_disk_size_gb
  omni_controller_proxmox_node           = var.omni_controller_proxmox_node
  omni_controller_datastore_id           = var.omni_controller_datastore_id
  omni_controller_template_id            = var.omni_controller_template_id
  omni_controller_image                  = var.omni_controller_image
  omni_controller_data_path              = var.omni_controller_data_path
  omni_controller_domain                 = var.omni_controller_domain
  omni_controller_tls_cert_path          = var.omni_controller_tls_cert_path
  omni_controller_tls_key_path           = var.omni_controller_tls_key_path
  omni_controller_tls_cert_pem           = var.omni_controller_tls_cert_pem
  omni_controller_tls_key_pem            = var.omni_controller_tls_key_pem
  omni_controller_direct_tls_termination = var.omni_controller_direct_tls_termination
  omni_controller_rotate_tls_on_change   = var.omni_controller_rotate_tls_on_change
}


output "talos_cluster_summary" {
  description = "Talos Omni cluster summary"
  value       = module.talos_omni.cluster_summary
}

output "talos_control_plane_nodes" {
  description = "Control plane node details"
  value       = module.talos_omni.control_plane_nodes
}

output "talos_worker_nodes" {
  description = "Worker node details"
  value       = module.talos_omni.worker_nodes
}

output "talos_all_nodes" {
  description = "All provisioned Talos nodes"
  value       = module.talos_omni.all_nodes
}

output "talos_omni_controller" {
  description = "Omni controller details and endpoints"
  value       = module.talos_omni.omni_controller
}
