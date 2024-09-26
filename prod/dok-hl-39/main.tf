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
    tfe = {
      source = "hashicorp/tfe"
      version = "0.58.1"
    }
  }

}

data "tfe_workspace" "d3-homelab" {
  name         = "d3-homelab"
  organization = "ncdv-org"
}

data "tfe_variables" "d3-homelab" {
  workspace_id = data.tfe_workspace.d3-homelab.id
}



module "pve" {
  source  = "app.terraform.io/ncdv-org/pve/d3"
  version = "1.0.0"
  lxc-common = module.vars.pve.lxc-common

}