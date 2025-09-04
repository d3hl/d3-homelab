# Add talos module
module "komodo-1" {
  source  = "app.terraform.io/d3-org/vm/pve"
  username = var.virtual_environment_username
  api=var.virtual_environment_api_token
  insecure=var.virtual_environment_insecure
  }