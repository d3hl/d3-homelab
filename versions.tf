terraform {
  
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.65.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.5.0"
    }
  }

  required_version = ">= 0.6.0"
}