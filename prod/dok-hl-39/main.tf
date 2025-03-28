terraform {
  required_version = ">= 1.5.0"
  cloud {
    organization ="d3-org"
    workspaces {
      project = "hl-proj"
      name = "homelab"
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
      version = "0.73.0"
    }
  }

}
module "lxc" {
  source  = "app.terraform.io/d3-org/lxc/pve"
  version = "1.0.0"
  lxc-common = var.lxc-common
  endpoint   = var.endpoint
  api_token = var.api_token
  pveuser = var.pveuser
  pvepassword = var.pvepassword
  publickey = var.publickey
  vm_user = var.vm_user
}


