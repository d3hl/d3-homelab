terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }
  required_version = ">= 0.6.0"
}
#module "lxc" {
#  source = "../../modules/lxc"
#}
module "lxc" {
  source  = "app.terraform.io/ncdv-org/lxc/proxmox"
  version = "1.0.0"
  # insert required variables here
}