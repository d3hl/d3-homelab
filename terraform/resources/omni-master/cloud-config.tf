data "local_file" "ssh_public_key" {
  filename = "/home/d3/.ssh/d3_tf.pub"
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  count        = 2
  content_type = "snippets"
  datastore_id = "cFS"
  node_name    = var.virtual_environment_node_name

  #hostname: test-${count.index}
  source_raw {
    data = <<-EOF
    #cloud-config
    timezone: Asia/Singapore
    hostname: omni-${count.index}
    users:
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

    file_name = "user-data-cloud-config-${count.index}.yaml"
    #file_name = "user-data-cloud-config}.yaml"
  }

}
