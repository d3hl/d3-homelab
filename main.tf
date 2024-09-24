#locals {
#    name_suffix = "${var.resource_tags["projects"]}-${var.resource_tags["environment"]}"
#}
terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.65.0"
    }
  }
}

module "dok-hl-39" {
  source = "./prod/dok-hl-39"
}