data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_file
}

resource "proxmox_virtual_environment_pool" "aap_pool" {
  pool_id = "aap-pool"
  comment = "Ansible Automation Platform VMs"
}

# ── Cloud-init snippets ──────────────────────────────────────────────────────

resource "proxmox_virtual_environment_file" "aap_gateway_user_data" {
  content_type = "snippets"
  datastore_id = var.cfs_datastore_id
  node_name    = var.rhel9_template_node

  source_raw {
    data      = <<-EOF
    #cloud-config
    hostname: aap-gateway
    timezone: Asia/Singapore
    users:
      - name: d3
        groups: [wheel]
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
    package_update: false
    runcmd:
      - systemctl enable --now qemu-guest-agent
    EOF
    file_name = "aap-gateway-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "aap_controller_user_data" {
  content_type = "snippets"
  datastore_id = var.cfs_datastore_id
  node_name    = var.rhel9_template_node

  source_raw {
    data      = <<-EOF
    #cloud-config
    hostname: aap-controller
    timezone: Asia/Singapore
    users:
      - name: d3
        groups: [wheel]
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
    package_update: false
    runcmd:
      - systemctl enable --now qemu-guest-agent
    EOF
    file_name = "aap-controller-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "aap_hub_user_data" {
  content_type = "snippets"
  datastore_id = var.cfs_datastore_id
  node_name    = var.rhel9_template_node

  source_raw {
    data      = <<-EOF
    #cloud-config
    hostname: aap-hub
    timezone: Asia/Singapore
    users:
      - name: d3
        groups: [wheel]
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
    package_update: false
    runcmd:
      - systemctl enable --now qemu-guest-agent
    EOF
    file_name = "aap-hub-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "aap_db_user_data" {
  content_type = "snippets"
  datastore_id = var.cfs_datastore_id
  node_name    = var.rhel9_template_node

  source_raw {
    data      = <<-EOF
    #cloud-config
    hostname: aap-db
    timezone: Asia/Singapore
    users:
      - name: d3
        groups: [wheel]
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
    package_update: false
    runcmd:
      - systemctl enable --now qemu-guest-agent
    EOF
    file_name = "aap-db-user-data.yaml"
  }
}

# ── VMs ──────────────────────────────────────────────────────────────────────

# Platform Gateway — reverse proxy / unified UI entry point
# Minimum: 2 vCPU, 4 GB RAM, 20 GB disk
resource "proxmox_cloned_vm" "aap_gateway" {
  node_name       = var.virtual_environment_node_name
  name            = "aap-gateway"
  tags            = ["rhel9", "aap", "gateway"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel9_template_vm_id
    source_node_name = var.rhel9_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_pool.id
  }

  cpu = {
    cores = 2
    type  = "host"
  }

  memory = {
    size = 4096
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = 30
      discard      = "on"
      iothread     = true
    }
  }

  network_device = {
    net0 = {
      bridge = "vmbr0"
      model  = "virtio"
    }
  }

  initialization = {
    ip_config = {
      ipv4 = {
        address = var.aap_gateway_ip
        gateway = var.network_gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.aap_gateway_user_data.id
  }
}

# Automation Controller — job execution engine
# Minimum: 4 vCPU, 16 GB RAM, 40 GB disk
resource "proxmox_cloned_vm" "aap_controller" {
  node_name       = var.virtual_environment_node_name
  name            = "aap-controller"
  tags            = ["rhel9", "aap", "controller"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel9_template_vm_id
    source_node_name = var.rhel9_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_pool.id
  }

  cpu = {
    cores = 4
    type  = "host"
  }

  memory = {
    size = 16384
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = 60
      discard      = "on"
      iothread     = true
    }
  }

  network_device = {
    net0 = {
      bridge = "vmbr0"
      model  = "virtio"
    }
  }

  initialization = {
    ip_config = {
      ipv4 = {
        address = var.aap_controller_ip
        gateway = var.network_gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.aap_controller_user_data.id
  }
}

# Automation Hub — private collection and EE registry
# Minimum: 4 vCPU, 8 GB RAM, 60 GB disk (more if hosting many collections)
resource "proxmox_cloned_vm" "aap_hub" {
  node_name       = var.virtual_environment_node_name
  name            = "aap-hub"
  tags            = ["rhel9", "aap", "hub"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel9_template_vm_id
    source_node_name = var.rhel9_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_pool.id
  }

  cpu = {
    cores = 4
    type  = "host"
  }

  memory = {
    size = 8192
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = 100
      discard      = "on"
      iothread     = true
    }
  }

  network_device = {
    net0 = {
      bridge = "vmbr0"
      model  = "virtio"
    }
  }

  initialization = {
    ip_config = {
      ipv4 = {
        address = var.aap_hub_ip
        gateway = var.network_gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.aap_hub_user_data.id
  }
}

# External PostgreSQL database
# Minimum: 2 vCPU, 8 GB RAM, 40 GB disk
resource "proxmox_cloned_vm" "aap_db" {
  node_name       = var.virtual_environment_node_name
  name            = "aap-db"
  tags            = ["rhel9", "aap", "database"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel9_template_vm_id
    source_node_name = var.rhel9_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap_pool.id
  }

  cpu = {
    cores = 2
    type  = "host"
  }

  memory = {
    size = 8192
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = 40
      discard      = "on"
      iothread     = true
    }
  }

  network_device = {
    net0 = {
      bridge = "vmbr0"
      model  = "virtio"
    }
  }

  initialization = {
    ip_config = {
      ipv4 = {
        address = var.aap_db_ip
        gateway = var.network_gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.aap_db_user_data.id
  }
}
