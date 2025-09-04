terraform {
  required_version = ">= 1.5.0"
  cloud {
    organization ="d3-org"
    workspaces {
      project = "hl-proj"
      name = "homelab"
    }
  }

}
    provider "proxmox" {
  endpoint=var.virtual_environment_endpoint
    ssh {
        agent = true
        username = var.vmuser

      }
      }
