module "k8s" {
  source  = "app.terraform.io/ncdv-org/k8s/pve"
  version = "1.0.1"
  talos-common = var.talos-common
  talos_ips = var.talos_ips
  pveuser = var.pveuser
  endpoint = "https://192.168.2.11:8006"
  pvepassword = var.pvepassword
  api_token = var.api_token
  vm_user = var.vm_user
  
}
