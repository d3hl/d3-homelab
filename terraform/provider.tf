terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.84.1" # x-release-please-version
    }
  }

}
    provider "proxmox" {
        endpoint = var.virtual_environment_endpoint
        api_token = var.virtual_environment_api_token
        #username  = var.virtual_environment_username
        #password  = var.virtual_environment_password
        insecure = true 
    ssh {
      node {
        name    = "pve10"
        address = "10.10.10.10"
      }
    node {
      name    = "pve14"
      address = "10.10.10.14"
    }
    node {
      name    = "nodeA"
      address = "10.10.10.18"
    }
    node {
      name    = "nodeB"
      address = "10.10.10.15"
    }
    node {
      name    = "nodeC"
      address = "10.10.10.19"
    }
        agent = true
        username = var.virtual_environment_username
      }
      }
