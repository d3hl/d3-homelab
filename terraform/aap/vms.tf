locals {
  aap_vm_names = {
    gateway    = "aap-gateway"
    controller = "aap-controller"
    hub        = "aap-hub"
    db         = "aap-db"
  }
}

resource "proxmox_virtual_environment_pool" "aap_image_mode" {
  pool_id = "aap-image-mode"
  comment = "Red Hat Ansible Automation Platform image-mode homelab"
}

resource "proxmox_cloned_vm" "aap" {
  for_each = var.aap_nodes

  node_name       = coalesce(each.value.node, var.virtual_environment_node_name)
  name            = local.aap_vm_names[each.key]
  tags            = ["rhel10", "bootc", "aap", each.value.role]
  stop_on_destroy = true

  clone = {
    source_vm_id     = coalesce(each.value.template, var.rhel_bootc_template_vm_id)
    source_node_name = var.rhel_bootc_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_image_mode.id
  }

  cpu = {
    cores = each.value.cores
    type  = "host"
  }

  memory = {
    size = each.value.memory
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = each.value.disk
      discard      = "on"
      iothread     = true
    }
  }

  network_device = {
    net0 = {
      bridge = var.network_bridge
      model  = "virtio"
      tag    = var.network_vlan_tag
    }
  }

  initialization = {
    ip_config = {
      ipv4 = {
        address = each.value.ip
        gateway = var.network_gateway
      }
    }
  }
}
