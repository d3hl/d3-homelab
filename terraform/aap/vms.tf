data "local_file" "ssh_public_key" {
  filename = "/home/d3/.ssh/d3_tf.pub"
}

resource "proxmox_virtual_environment_pool" "aap" {
  pool_id = "aap"
  comment = "Ansible Automation Platform 2.6 containerized all-in-one"
}

resource "proxmox_virtual_environment_file" "aap_user_data" {
  content_type = "snippets"
  datastore_id = var.cfs_datastore_id
  node_name    = var.virtual_environment_node_name

  source_raw {
    file_name = "aap-user-data.yaml"
    data      = <<-EOF
    #cloud-config
    hostname: aap
    fqdn: aap.${var.aap_dns_domain}
    manage_etc_hosts: true
    package_update: false
    users:
      - default
      - name: d3
        groups:
          - wheel
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
      - systemctl enable --now qemu-guest-agent
      - hostnamectl set-hostname aap.${var.aap_dns_domain}
    EOF
  }
}

resource "proxmox_cloned_vm" "aap" {
  node_name       = var.virtual_environment_node_name
  name            = "aap"
  tags            = ["rhel10", "aap26", "container", "all-in-one"]
  stop_on_destroy = true

  clone = {
    source_vm_id     = var.rhel10_template_vm_id
    source_node_name = var.rhel10_template_node
    full             = true
    pool_id          = proxmox_virtual_environment_pool.aap.id
  }

  cpu = {
    cores = var.aap_cores
    type  = "host"
  }

  memory = {
    size = var.aap_memory
  }

  disk = {
    virtio0 = {
      datastore_id = var.datastore_id
      size         = var.aap_disk_size
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
    datastore_id      = var.cfs_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.aap_user_data.id
    ip_config = {
      ipv4 = {
        address = var.aap_ip
        gateway = var.network_gateway
      }
    }
  }
}
