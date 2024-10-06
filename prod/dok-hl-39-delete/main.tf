terraform {
  required_version = ">= 1.5.0"
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
      alias = "dok-hl-39"
    }
  }

}
module "lxc" {
  source  = "app.terraform.io/ncdv-org/lxc/pve"
  version = "1.0.0"
  lxc-common = var.lxc-common
  endpoint   = var.endpoint
  api_token = var.api_token
  pveuser = var.pveuser
  pvepassword = var.pvepassword
  publickey = var.publickey
  vm_user = var.vm_user
}


