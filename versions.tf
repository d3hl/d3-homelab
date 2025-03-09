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
      version = "0.66.1"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.5.0"
    }
  }

  required_version = ">= 1.1.0"
}