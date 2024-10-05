module "k8s" {
  source  = "app.terraform.io/ncdv-org/k8s/pve"
  version = "1.0.0"
  lxc-common = var.lxc-common
  talos_ips = var.talos_ips
}