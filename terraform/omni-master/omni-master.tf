data "local_file" "ssh_public_key" {
  filename = "/home/d3/.ssh/d3_tf.pub"
}

resource "proxmox_virtual_environment_cloned_vm" "omni-master" {
  node_name = var.virtual_environment_node_name
  name      = "omni-master"

  clone = {
    source_vm_id = var.ubuntu_template
    full         = true
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 100
      discard      = "on"
      iothread     = true
    }
  }

  memory = {
    size    = 8192
    balloon = 4096
  }

  cpu = {
    cores = 4
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.omni_master_user_data.id
  }
}

resource "proxmox_virtual_environment_file" "omni_master_user_data" {
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: omni-master
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
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "omni-master-user-data.yaml"
  }
}

output "omni_master_vm_id" {
  description = "ID of the omni-master VM"
  value       = proxmox_virtual_environment_cloned_vm.omni-master.id
}
