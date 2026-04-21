locals {
  cloud_config_cp_content = templatefile("${path.module}/cloud-config-cp.tpl", {
    cluster_name  = var.cluster_name
    talos_version = var.talos_version
    ssh_key       = trimspace(data.local_file.ssh_public_key.content)
  })

  cloud_config_worker_content = templatefile("${path.module}/cloud-config-worker.tpl", {
    cluster_name  = var.cluster_name
    talos_version = var.talos_version
    ssh_key       = trimspace(data.local_file.ssh_public_key.content)
  })
}

resource "proxmox_cloned_vm" "talos_node" {
  for_each = local.node_config

  node_name = each.value.proxmox_node
  name      = each.value.name

  clone = {
    source_vm_id = var.vm_template_id
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = var.disk_size_gb
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = var.memory_mb
    balloon = var.memory_mb / 2
  }

  cpu = {
    cores = var.cpu_cores
  }

  tags = [
    "talos",
    "cluster:${var.cluster_name}",
    each.value.is_cp ? "role:controlplane" : "role:worker",
    "managed-by:terraform"
  ]
}




resource "proxmox_virtual_environment_file" "talos_cloud_init_control_plane" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.proxmox_nodes[0]

  source_raw {
    data      = local.cloud_config_cp_content
    file_name = "talos-cp-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "talos_cloud_init_worker" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.proxmox_nodes[0]

  source_raw {
    data      = local.cloud_config_worker_content
    file_name = "talos-worker-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "omni_controller_cloud_init" {
  count = var.omni_controller_enabled ? 1 : 0

  content_type = "snippets"
  datastore_id = local.omni_controller_datastore
  node_name    = local.omni_controller_target_node

  source_raw {
    data      = local.cloud_config_omni_content
    file_name = "talos-omni-controller-cloud-config.yaml"
  }
}

resource "proxmox_cloned_vm" "omni_controller" {
  count = var.omni_controller_enabled ? 1 : 0

  node_name = local.omni_controller_target_node
  name      = var.omni_controller_name

  clone = {
    source_vm_id = local.omni_controller_template
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = local.omni_controller_datastore
      size_gb      = var.omni_controller_disk_size_gb
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = var.omni_controller_memory_mb
    balloon = var.omni_controller_memory_mb / 2
  }

  cpu = {
    cores = var.omni_controller_cpu_cores
  }

  tags = [
    "talos",
    "omni",
    "cluster:${var.cluster_name}",
    "role:omni-controller",
    "managed-by:terraform"
  ]

  depends_on = [proxmox_virtual_environment_file.omni_controller_cloud_init]
}


