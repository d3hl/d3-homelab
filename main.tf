module "dok-hl-39" {
  source = "./prod/dok-hl-39"
  lxc-common = var.lxc-common
  endpoint   = var.endpoint
  pvepassword = var.pvepassword
  api_token = var.api_token
  pveuser = var.pveuser
  }
module "talos-k8s" {
  source = "./prod/talos-k8s"
  endpoint   = var.endpoint
  pvepassword = var.pvepassword
  api_token = var.api_token
  pveuser = var.pveuser
  talos_ips = talos_ips
  talos-common = var.talos-common
  }