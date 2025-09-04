module "komodo-1" {
  source  = "app.terraform.io/d3-org/vm/pve"
  version = "1.0.0"
   endpoint=var.virtual_environment_endpoint
#  username = var.virtual_environment_username
   api_token = var.virtual_environment_api_token
#  endpoint=var.virtual_environment_endpoint
  #api=var.virtual_environment_api_token
  #nodename= var.virtual_environment_node_name
  #insecure=var.virtual_environment_insecure
  #storage=virtual_environment_storage
  #url=var.latest_debian_13_bookworm_qcow2_img_url
  }