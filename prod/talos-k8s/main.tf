module "k8s" {
  source  = "app.terraform.io/ncdv-org/k8s/pve"
  version = "1.0.0"
  talos-common = var.talos-common
  talos_ips = var.talos_ips
  pveuser = var.pveuser
  pvepassword = var.pvepassword
  api_token = var.api_token
  vm_user = var.vm_user
  
}
