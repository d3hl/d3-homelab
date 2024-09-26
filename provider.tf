terraform {

  cloud {
    organization ="ncdv-org"

    workspaces {
      project = "ncdv-hl"
      name = "d3-homelab"
    }
  }
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
      source = "bpg/proxmox"
      version = "0.65.0"
    }
  }

}
    provider "proxmox" {
      endpoint = var.endpoint 
      username = var.pveuser
      password = var.pvepassword
      insecure = true 
    ssh {
        agent = true
        username = var.pveuser

      }
      }