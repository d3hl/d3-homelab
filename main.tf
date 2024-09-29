module "dok-hl-39" {
  source = "./prod/dok-hl-39"
  lxc-common = var.lxc-common
  endpoint   = var.endpoint
  pvepassword = var.pvepassword
  api_token = var.api_token
  pveuser = var.pveuser
  }