module "komodo" {
  #source  = "app.terraform.io/d3-org/vm/pve"
  source  = "./modules/komodo"
  virtual_environment_endpoint = var.virtual_environment_endpoint
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_username = var.virtual_environment_username
  ssh_public_key = var.ssh_public_key
  }
#module "lxc" {
#  #source  = "app.terraform.io/d3-org/vm/pve"
#  source  = "./modules/lxc"
#  virtual_environment_endpoint = var.virtual_environment_endpoint
#  virtual_environment_api_token = var.virtual_environment_api_token
#  virtual_environment_node_name = var.virtual_environment_pve10_name
#  virtual_environment_username = var.virtual_environment_username
#  ssh_public_key = data.local_file.ssh_public_key.content
#  }
