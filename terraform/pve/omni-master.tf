resource "proxmox_virtual_environment_file" "omni_master_user_data" {
  content_type = "snippets"
  datastore_id = var.cfs_datastore_id
  node_name    = var.virtual_environment_node_nodeB

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
    EOF

    file_name = "omni-master-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_cloned_vm" "omni_master" {
  node_name       = var.virtual_environment_node_nodeB
  name            = "omni-master"
  tags            = ["ubuntu", "omni"]
  stop_on_destroy = true

  clone = {
    source_vm_id = proxmox_virtual_environment_vm.ubuntu_template.vm_id
    full         = true
  }

  cpu = {
    cores = 4
  }

  memory = {
    size    = 8192
    balloon = 4096
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size_gb      = 100
      discard      = "on"
      iothread     = true
    }
  }

}

output "omni_master_vm_id" {
  description = "Proxmox VM ID of omni-master"
  value       = proxmox_virtual_environment_cloned_vm.omni_master.id
}
