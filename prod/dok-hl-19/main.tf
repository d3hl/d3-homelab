terraform {
  
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }

  required_version = ">= 0.6.0"
}
module "lxc" {
  source = "../../modules/lxc"
}

locals {
  required_tags = {
    project     = var.project_name,
    workspace   = var.workspace,
  }
  tags = merge(var.resource_tags, local.required_tags)
}