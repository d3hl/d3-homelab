terraform {
  
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.65.0"
    }
  }

  required_version = ">= 0.6.0"
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


