terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.84.0" # x-release-please-version
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
      name    = "pve11"
      address = "10.10.10.11"
    }
    node {
      name    = "pve14"
      address = "10.10.10.14"
    }
        agent = true
        username = var.virtual_environment_username
      }
      }
