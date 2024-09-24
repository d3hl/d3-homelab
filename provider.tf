    provider "proxmox" {
        endpoint = "${var.d3-pve-credentials.endpoint}" 
        username = "${var.d3-pve-credentials.pve_user}"
        password = "${var.d3-pve-credentials.pve_password}" 
        insecure = true 
    ssh {
        agent = true
        username = "${var.pve_user}"
      }
      }