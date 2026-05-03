resource "proxmox_cloned_vm" "k1" {
  node_name       = var.virtual_environment_node_nodeA
  name            = "k1"
  tags            = ["ubuntu","komodo"]
  stop_on_destroy = true

  clone = {
    source_vm_id = var.ubuntu_template_vm_id
    source_node_name = "nodeF"
    full         = true
    pool_id = proxmox_virtual_environment_pool.komodo_pool.id
  }
}

resource "proxmox_cloned_vm" "k2" {
  node_name       = var.virtual_environment_node_nodeB
  name            = "k2"
  tags            = ["ubuntu","komodo"]
  stop_on_destroy = true

  clone = {
    source_vm_id = var.ubuntu_template_vm_id
    source_node_name = "nodeF"
    full         = true
    pool_id = proxmox_virtual_environment_pool.komodo_pool.id
  }
}

resource "proxmox_cloned_vm" "k3" {
  node_name       = var.virtual_environment_node_name
  name            = "k3"
  tags            = ["ubuntu","komodo"]
  stop_on_destroy = true

  clone = {
    source_vm_id = var.ubuntu_template_vm_id
    source_node_name = "nodeF"
    full         = true
    pool_id = proxmox_virtual_environment_pool.komodo_pool.id
  }
}
resource "proxmox_cloned_vm" "k4" {
  node_name       = var.virtual_environment_node_nodeF
  name            = "k4"
  tags            = ["ubuntu","komodo"]
  stop_on_destroy = true

  clone = {
    source_vm_id = var.ubuntu_template_vm_id
    source_node_name = "nodeF"
    full         = true
    pool_id = proxmox_virtual_environment_pool.komodo_pool.id
  }
}
resource "proxmox_virtual_environment_pool" "komodo_pool" {
  pool_id = "komodo-pool"
  comment = "Komodo k-cluster VMs"
}

#Output
output "k_cluster_vm_ids" {
  description = "Proxmox VM IDs for k1, k2, k3, k4"
  value = {
    k1 = proxmox_cloned_vm.k1.id
    k2 = proxmox_cloned_vm.k2.id
    k3 = proxmox_cloned_vm.k3.id
    k4 = proxmox_cloned_vm.k4.id
  }
}
output "pool_vm_ids" {
  description = "Proxmox VM IDs in komodo-pool"
  value = proxmox_virtual_environment_pool.komodo_pool.id
}