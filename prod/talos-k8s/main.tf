module "k8s" {
  source  = "app.terraform.io/d3-org/k8s/pve"
  version = "1.0.0"
  talos-common = var.talos-common
  credentials = var.credentials
  talos_ips = var.talos_ips
  #pveuser = var.pveuser
  #endpoint = "https://192.168.2.11:8006"
  #pvepassword = var.pvepassword
  #api_token = var.api_token
  #vm_user = var.vm_user
#  pveuser = var.credentials.pveuser
#  pvepassword = var.credentials.pvepassword
#  api_token = var.credentials.api_token
#  endpoint = var.credentials.endpoint

  
}
