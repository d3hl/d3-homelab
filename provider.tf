terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.0" # x-release-please-version
    }
  }

}
    provider "proxmox" {
        endpoint = var.virtual_environment_endpoint
        api_token = var.virtual_environment_api_token
        insecure = insecure 
    ssh {
        agent = true
#        username = "root" 
      }
      }
