module "k8s" {
  source  = "app.terraform.io/ncdv-org/pve/k8s"
  version = "1.0.0"
  lxc-common = var.lxc-common
  talos_ips = var.talos_ips
  endpoint   = var.endpoint
  api_token = var.api_token
  pveuser = var.pveuser
}