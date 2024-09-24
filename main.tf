terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.65.0"
    }
  }
}
variable "proxmox_lxc-common" {
  
}
module "dok-hl-39" {
  source = "./prod/dok-hl-39"
}