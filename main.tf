module "dok-hl-39" {
  source = "./prod/dok-hl-39"
  lxc-common = var.lxc-common
  endpoint   = var.endpoint
  pvepassword = var.pvepassword
  api_token = var.api_token
  pveuser = var.pveuser
  vm_user = var.vm_user
 }
module "talos-k8s" {
  source = "./prod/talos-k8s"
  endpoint   = var.endpoint
  pvepassword = var.pvepassword
  api_token = var.api_token
  pveuser = var.pveuser
  talos_ips = var.talos_ips
  vm_user = var.vm_user
  }