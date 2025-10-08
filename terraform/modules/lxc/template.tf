data "local_file" "ssh_public_key" {
  filename = "/home/d3/.ssh/id_ed.pub" 
}

resource "proxmox_virtual_environment_container" "debianlxc-template" {
  description = "Managed by Terraform"

  start_on_boot = "true"

  disk {
    datastore_id = var.virtual_environment_storage
    size         = 4
  }

  #mount_point {
    // volume mount
   # volume = var.virtual_environment_storage
    #size   = "4G"
    #path   = "mnt/local"
  #}

  initialization {
    dns {
      servers = ["10.10.10.1"]
    }

    hostname = "debian-lxc-template"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(data.local_file.ssh_public_key.content )]
    }
  }

  network_interface {
    name = "veth0"
    mtu  = 1450
  }

  node_name = var.virtual_environment_pve10_name
  #node_name = data.proxmox_virtual_environment_nodes.example.names[0]

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.latest_debian_12_bookworm_qcow2_img.id
    type             = "debian"
  }

  #pool_id  = proxmox_virtual_environment_pool.example.id
  template = true

  // use auto-generated vm_id

  tags = [
    "container",
    "terraform",
  ]

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "proxmox_virtual_environment_container" "bastion" {
  disk {
    datastore_id = var.virtual_environment_storage
  }

  clone {
    vm_id = proxmox_virtual_environment_container.debianlxc_template.id
  }

  tags = [
    "container",
  ]


  initialization {
    hostname = "bastion"
  }

  #mount_point {
    // bind mount, requires root@pam
   # volume = "/mnt/bindmounts/shared"
   # path   = "/shared"
  #}

  #node_name = data.proxmox_virtual_environment_nodes.example.names[0]
  node_name= pve10
  pool_id   = proxmox_virtual_environment_pool.example.id
  # Set the protection flag to prevent the deletion/update operations for the container and its disks.
  # protection = true
  vm_id = 100
}

output "resource_proxmox_virtual_environment_container_bastion_id" {
  value = proxmox_virtual_environment_container.bastion.id
}