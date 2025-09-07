resource "proxmox_virtual_environment_vm" "komodo2" {
  name      = "Komodo2"
  node_name = var.virtual_environment_node_name

  clone {
    vm_id = proxmox_virtual_environment_vm.debian-template.id
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = 4096
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
data "local_file" "ssh_public_key" {
  filename = "/home/d3/.ssh/id_ed.pub" 
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "cephfs"
  node_name    = var.virtual_environment_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: Komodo2
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

    file_name = "user-data-cloud-config.yaml"
  }
}
#output "vm_ipv4_address" {
  #value = proxmox_virtual_environment_vm.komodo1.ipv4_addresses[0]
#}