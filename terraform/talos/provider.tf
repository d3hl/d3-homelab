terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.100.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  insecure  = var.virtual_environment_insecure
  api_token = var.virtual_environment_api_token
  username  = var.virtual_environment_username
}
