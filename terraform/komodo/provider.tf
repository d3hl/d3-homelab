terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "d3-org"
    workspaces {
      project = "homelab"
      name    = "komodo"
    }
  }

  required_providers {
    proxmox = {
      source  = "sebastianfs82/komodo"
      version = "~> 0.10"
    }
  }
}
provider "komodo" {
  endpoint   = "https://10.10.10.35:8120"
  api_key    = var.komodo_api_key
  api_secret = var.komodo_api_secret
}