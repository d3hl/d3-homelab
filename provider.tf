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
    required_version = "~> 1.13.1"
}
    provider "proxmox" {
        endpoint = var.virtual_environment_endpoint
        api_token = var.virtual_environment_api_token
        insecure = var.virtual_environment_insecure
    ssh {
        agent = true
        username = var.virtual_environment_ssh_username 
        #private_key = file("~/.ssh/id_ed")
      }
      }
