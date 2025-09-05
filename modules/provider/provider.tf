terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  username = var.virtual_environment_username
  password = var.virtual_environment_password
  insecure = true
  ssh {
    agent = true
  }
}