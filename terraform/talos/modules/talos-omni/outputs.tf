output "control_plane_nodes" {
  description = "Control plane node information"
  value = {
    for k, v in proxmox_cloned_vm.talos_node :
    v.name => {
      vmid       = v.id
      node       = v.node_name
      ip_address = "10.11.11.${100 + k}"
    }
    if k < var.control_plane_count
  }
}

output "worker_nodes" {
  description = "Worker node information"
  value = {
    for k, v in proxmox_cloned_vm.talos_node :
    v.name => {
      vmid       = v.id
      node       = v.node_name
      ip_address = "10.11.11.${100 + k}"
    }
    if k >= var.control_plane_count
  }
}

output "cluster_summary" {
  description = "Talos Omni cluster summary"
  value = {
    cluster_name        = var.cluster_name
    total_nodes         = var.control_plane_count + var.worker_count
    control_plane_count = var.control_plane_count
    worker_count        = var.worker_count
    talos_version       = var.talos_version
    ip_range            = "10.11.11.100-10.11.11.${100 + var.control_plane_count + var.worker_count - 1}"
    datastore           = var.datastore_id
  }
}

output "all_nodes" {
  description = "All provisioned nodes"
  value = {
    for k, v in proxmox_cloned_vm.talos_node :
    v.name => {
      vmid       = v.id
      node       = v.node_name
      ip_address = "10.11.11.${100 + k}"
      role       = k < var.control_plane_count ? "controlplane" : "worker"
    }
  }
}

output "omni_controller" {
  description = "Omni controller node details"
  value = var.omni_controller_enabled ? {
    name         = proxmox_cloned_vm.omni_controller[0].name
    vmid         = proxmox_cloned_vm.omni_controller[0].id
    proxmox_node = proxmox_cloned_vm.omni_controller[0].node_name
    ip_address   = var.omni_controller_ip
    domain       = var.omni_controller_domain != "" ? var.omni_controller_domain : null
    image        = var.omni_controller_image
    endpoints = {
      ui    = var.omni_controller_domain != "" ? "https://${var.omni_controller_domain}" : "https://${var.omni_controller_ip}"
      grpc  = "${var.omni_controller_ip}:8099"
      talos = "${var.omni_controller_ip}:443"
    }
  } : null
}

