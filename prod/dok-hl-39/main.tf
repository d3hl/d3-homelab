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

module "lxc" {
  source  = "app.terraform.io/ncdv-org/lxc/pve"
  version = "1.0.0"
  lxc-common = var.lxc-common
  endpoint   = var.endpoint
  api_token = var.api_token
  pveuser = var.pveuser
}


