resource "proxmox_virtual_environment_file" "kmd_2_user_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: kmd-2
    timezone: Asia/Singapore
    users:
      - default
      - name: d3
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
    EOF

    file_name = "kmd-2-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_cloned_vm" "kmd-2" {
  node_name       = var.virtual_environment_node_name
  name            = "kmd-2"
  tags            = ["ubuntu", "komodo"]
  stop_on_destroy = true

  clone = {
    source_vm_id = var.ubuntu_template
    full         = true
  }

  cpu = {
    cores = 4
  }

  memory = {
    size    = 16384
    balloon = 8192
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 100
      discard      = "on"
      iothread     = true
    }
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.kmd_2_user_data.id
  }
}

output "vm_id" {
  description = "Proxmox VM ID of kmd-2"
  value       = proxmox_virtual_environment_cloned_vm.kmd-2.id
}
