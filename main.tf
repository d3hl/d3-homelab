# Add talos module
module "talos-k8s" {
  source = "./prod/talos-k8s"
  talos-common = var.talos-common
  talos_ips = var.talos_ips
  pveuser = var.pveuser
  endpoint = var.endpoint
  pvepassword = var.pvepassword
  api_token = var.api_token
  vm_user = var.vm_user
  }