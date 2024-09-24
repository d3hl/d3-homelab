    provider "proxmox" {
        endpoint = endpoint 
        username = pve_user
        password = pve_password 
        insecure = true 
    ssh {
        agent = true
        username = var.pve_user
      }
      }