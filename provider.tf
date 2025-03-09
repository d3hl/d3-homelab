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
#      endpoint = var.endpoint 
#      username = var.pveuser
#      password = var.pvepassword
      endpoint = var.credentials.endpoint
      username = var.credentials.pveuser
      password = var.credentials.pvepassword
      insecure = true 
    ssh {
        agent = true
        username = var.vmuser

      }
      }
