module "pve" {
  source  = "app.terraform.io/ncdv-org/pve/d3"
  version = "1.0.0"
  lxc-common = var.lxc-common
  endpoint   = var.endpoint
  api_token = var.api_token
  pveuser = var.pveuser
}