terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.0" # x-release-please-version
    }
  }

}
    provider "proxmox" {
        endpoint = var.virtual_environment_endpoint
        api_token = var.virtual_environment_api_token
        insecure = true 
    ssh {
      node {
        name    = "pve10"
        address = "10.10.10.10"
      }
      node {
        name    = "nodeB"
        address = "10.10.10.15"
      }
      node {
        name    = "nodeC"
        address = "10.10.10.19"
      }
    node {
      name    = "nodeA"
      address = "10.10.10.18"
    }
    node {
      name    = "pve14"
      address = "10.10.10.14"
    }
        agent = true
        username = "d3"
        #username = var.virtual_environment_username
      }
      }
