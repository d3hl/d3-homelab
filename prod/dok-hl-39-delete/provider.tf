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