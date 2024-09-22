terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }
  required_version = ">= 0.6.0"
}

variable "lxc-vars"  {
    type = object({
    ct_datastore_template_location      = string 
    ct_datastore_storage_location       = string
    ct_source_file_path                 = string
    node_name                           = string
    hostname                            = string
    dns_domain                          = string
    os_type                             = string
    time_zone                           = string
    sockets                             = string
    cores                               = number
    memory                              = number
    ballon                              = number 
    disksize                            = number
    vga                                 = string
    })
}
variable "network" {
    type = object({
    vlan_id   = number 
    subnet    = string
    bridge    = string
    gateway   = string
    dns       = string 
  })
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
  datastore_id = var.ct_datastore_template_location
  node_name    = "pve11"

  source_file {
    path = var.ct_source_file_path
  }
}

resource "proxmox_virtual_environment_container" "debian_container" {
  description   = "Managed by Terraform"
  node_name     = "pve11"
  start_on_boot = true
  tags          = ["terraform", "lxc"]
  unprivileged  = true
  vm_id         = 117
  
  cpu {
    architecture = "amd64"
    cores        = var.cores
  }

  disk {
    datastore_id = var.ct_datastore_storage_location
    size         = var.disksize
  }

  memory {
    dedicated = var.memory
    swap      = 0
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_file.debian_container_template.id
    type             = var.os_type
  }

  initialization {
    hostname = var.hostname

    dns {
      domain = var.dns_domain
      servers = var.dns
    }

    ip_config {
      ipv4 {
        address = var.ipv4
        gateway = var.gateway
      }
    }
    user_account {
      keys     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3/K4Fk9hgVBYcQjpOM83nRwxAE8yPhFzD1Y1ur+2JF d3"]
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