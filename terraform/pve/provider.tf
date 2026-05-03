terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "d3-org"
    workspaces {
      project = "homelab"
      name    = "pve"
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.105.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token
  insecure  = true

  ssh {
    agent    = true
    username = var.virtual_environment_username

    node {
      name    = "nodeA"
      address = "10.10.10.18"
    }
    node {
      name    = "nodeB"
      address = "10.10.10.15"
    }
    node {
      name    = "nodeD"
      address = "10.10.10.17"
    }
    node {
      name    = "nodeF"
      address = "10.10.10.10"
    }
  }
}
