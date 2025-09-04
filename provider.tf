terraform {
  required_version = ">= 1.5.0"
  cloud {
    organization ="d3-org"
    workspaces {
      project = "hl-proj"
      name = "d3-homelab"
    }
  }

}
    provider "proxmox" {
  endpoint=var.virtual_environment_endpoint
    ssh {
        agent = true
        username = var.virtual_environment_ssh_username

      }
      }
