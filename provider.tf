terraform {
  required_version = ">= 1.5.0"
  cloud {
    organization ="ncdv-org"
    workspaces {
      project = "ncdv-hl"
      name = "d3-homelab"
    }
  }

}
    provider "proxmox" {
      endpoint = var.endpoint 
      username = var.pveuser
      password = var.pvepassword
      insecure = true 
    ssh {
        agent = true
        username = var.pveuser

      }
      }
