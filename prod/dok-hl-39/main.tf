terraform {
  required_providers {
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