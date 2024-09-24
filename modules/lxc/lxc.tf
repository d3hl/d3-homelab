terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }
  required_version = ">= 0.6.0"
}


resource "random_password" "container_root_password" {
  length           = 24
  override_special = "_%@"
  special          = true
}

output "container_root_password" {
  value     = random_password.container_root_password.result
  sensitive = true
}

resource "proxmox_virtual_environment_file" "debian_container_template" {
  content_type = "vztmpl"
  datastore_id = local.ct_datastore_template_location
  node_name    = "pve11"

  source_file {
    path = local.ct_source_file_path
  }
}

resource "proxmox_virtual_environment_container" "debian_container" {
  description   = "Managed by Terraform"
  node_name     = "${var.lxc-common.node_name}"
  start_on_boot = true
  tags          = ["terraform", "lxc"]
  unprivileged  = true
  vm_id         = "${var.lxc-common.vm_id}"
  
  cpu {
    architecture = "amd64"
    cores        = "${var.lxc-common.cores}"
  }

  disk {
    datastore_id = local.ct_datastore_storage_location
    size         = "${var.lxc-common.disksize}"
  }

  memory {
    dedicated = "${var.lxc-common.memory}"
    swap      = 0
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_file.debian_container_template.id
    type             = local.os_type
  }

  initialization {
    hostname = "${var.lxc-common.hostname}"

    dns {
      domain = "${var.dns_domain}"
      servers = "${var.dns}"
    }

    ip_config {
      ipv4 {
        address = "${var.lxc-common.ipv4}"
        gateway = "${var.lxc-common.gateway}"
      }
    }
    user_account {
      keys     = var.d3-pve-credentials.publickey
      password = random_password.container_root_password.result
    }
  }
  network_interface {
    name       = var.ct_bridge
  }

  features {
    nesting = true
    fuse    = false
  }
}