    provider "proxmox" {
        endpoint = var.endpoint 
        username = var.user.
        password = var.pve_password 
        insecure = true 
    ssh {
        agent = true
        username = var.pve_user
      }
      }