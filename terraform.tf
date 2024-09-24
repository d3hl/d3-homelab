terraform {

  cloud {
    organization ="ncdv-org"

    workspaces {
      project = "ncdv-hl"
      name = "d3-homelab"
    }
  }
    required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }

  required_version = ">= 0.6.0"

}