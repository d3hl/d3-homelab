    provider "proxmox" {
        endpoint = var.credentials.endpoint 
        username = var.credentials.pve_user
        password = var.credentials.pve_password 
        insecure = true 
    ssh {
        agent = true
        username = var.credentials.pve_user
      }
      }