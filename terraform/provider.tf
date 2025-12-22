terraform {
  cloud {
    organization = "d3-org"
    workspaces {
      name = "komodo"
    }
  }
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.8" # x-release-please-version
    }
  }

}
provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token
  username  = var.virtual_environment_username
  insecure  = true
  ssh {
    agent    = true
    username = "d3"
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
      name    = "nodeC"
      address = "10.10.10.19"
    }
  }

}