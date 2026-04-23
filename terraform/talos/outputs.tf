output "controlplane_vm_ids" {
  description = "Proxmox VM IDs for control plane nodes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.controlplane :
    name => vm.id
  }
}

output "worker_vm_ids" {
  description = "Proxmox VM IDs for worker nodes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.worker :
    name => vm.id
  }
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = var.cluster_endpoint
}

output "kubeconfig" {
  description = "Kubernetes kubeconfig — write to ~/.kube/config or use KUBECONFIG env var"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "Talos client config — write to ~/.talos/config or use TALOSCONFIG env var"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}
