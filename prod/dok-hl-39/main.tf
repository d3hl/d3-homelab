module "lxc" {
  source  = "app.terraform.io/ncdv-org/lxc/pve"
  version = "1.0.0"
  lxc-common = var.lxc-common
  endpoint   = var.endpoint
  api_token = var.api_token
  pveuser = var.pveuser
  pvepassword = pve_password
  public = var.publickey
}


