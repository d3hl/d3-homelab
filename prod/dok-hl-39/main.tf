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
module "pve" {
  source  = "app.terraform.io/ncdv-org/pve/d3"
  version = "1.0.0"
  lxc-common = var.lxc-common
}