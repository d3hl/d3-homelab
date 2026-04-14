data "local_file" "ssh_public_key" {
  filename = "/home/d3/.ssh/d3_tf.pub"
}

# Debian VM 1
resource "proxmox_virtual_environment_cloned_vm" "debian_1" {
  node_name = var.virtual_environment_node_name
  name      = "debian-1"

  clone = {
    source_vm_id = 999 # Reference to ubuntu template ID
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 50
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = 4096
    balloon = 2048
  }

  cpu = {
    cores = 2
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.debian_1_user_data.id
  }
}

# Debian VM 2
resource "proxmox_virtual_environment_cloned_vm" "debian_2" {
  node_name = var.virtual_environment_node_name
  name      = "debian-2"

  clone = {
    source_vm_id = 999 # Reference to ubuntu template ID
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 50
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = 4096
    balloon = 2048
  }

  cpu = {
    cores = 2
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.debian_2_user_data.id
  }
}

# Debian VM 3
resource "proxmox_virtual_environment_cloned_vm" "debian_3" {
  node_name = var.virtual_environment_node_name
  name      = "debian-3"

  clone = {
    source_vm_id = 999 # Reference to ubuntu template ID
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 50
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = 4096
    balloon = 2048
  }

  cpu = {
    cores = 2
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.debian_3_user_data.id
  }
}

# Debian VM 4
resource "proxmox_virtual_environment_cloned_vm" "debian_4" {
  node_name = var.virtual_environment_node_name
  name      = "debian-4"

  clone = {
    source_vm_id = 999 # Reference to ubuntu template ID
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 50
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = 4096
    balloon = 2048
  }

  cpu = {
    cores = 2
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.debian_4_user_data.id
  }
}

# Debian VM 5
resource "proxmox_virtual_environment_cloned_vm" "debian_5" {
  node_name = var.virtual_environment_node_name
  name      = "debian-5"

  clone = {
    source_vm_id = 999 # Reference to ubuntu template ID
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 50
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = 4096
    balloon = 2048
  }

  cpu = {
    cores = 2
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.debian_5_user_data.id
  }
}

# Cloud-init configurations for each VM
resource "proxmox_virtual_environment_file" "debian_1_user_data" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: debian-1
    timezone: Asia/Singapore
    users:
      - default
      - name: d3
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        password: Abcd1234
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "debian-1-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "debian_2_user_data" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: debian-2
    timezone: Asia/Singapore
    users:
      - default
      - name: d3
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        password: Abcd1234
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "debian-2-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "debian_3_user_data" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: debian-3
    timezone: Asia/Singapore
    users:
      - default
      - name: d3
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        password: Abcd1234
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "debian-3-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "debian_4_user_data" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: debian-4
    timezone: Asia/Singapore
    users:
      - default
      - name: d3
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        password: Abcd1234
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "debian-4-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_file" "debian_5_user_data" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: debian-5
    timezone: Asia/Singapore
    users:
      - default
      - name: d3
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        password: Abcd1234
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "debian-5-user-data.yaml"
  }
}

# Outputs
output "debian_vms" {
  description = "IDs of the created Debian VMs"
  value = {
    debian_1_id = proxmox_virtual_environment_cloned_vm.debian_1.id
    debian_2_id = proxmox_virtual_environment_cloned_vm.debian_2.id
    debian_3_id = proxmox_virtual_environment_cloned_vm.debian_3.id
    debian_4_id = proxmox_virtual_environment_cloned_vm.debian_4.id
    debian_5_id = proxmox_virtual_environment_cloned_vm.debian_5.id
  }
}
