provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token

  insecure = true
  ssh {
    node {
      name    = "pve10"
      address = "10.10.10.10"
    }
    node {
      name    = "pve14"
      address = "10.10.10.14"
    }
    node {
      name    = "nodeA"
      address = "10.10.10.18"
    }
    node {
      name    = "nodeB"
      address = "10.10.10.15"
    }
    node {
      name    = "nodeC"
      address = "10.10.10.19"
    }
    agent    = true
    username = var.virtual_environment_username
  }
}
#
module "kmd1" {
  source                        = "./resources/kmd1"
  virtual_environment_username  = var.virtual_environment_username
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_api_token = var.virtual_environment_api_token
}
module "omni-master1" {
  source                        = "./resources/omni-master1"
  virtual_environment_username  = var.virtual_environment_username
  virtual_environment_endpoint  = var.virtual_environment_endpoint
  virtual_environment_api_token = var.virtual_environment_api_token
}

#module "Supermicro" {
# source = "./modules/Supermicro"
#virtual_environment_endpoint = var.virtual_environment_endpoint
#virtual_environment_api_token = var.virtual_environment_api_token
#virtual_environment_username = var.virtual_environment_username
# pass the debian cloud image file id exported by the komodo module
#debian_cloud_image_file_id = module.komodo.debian_cloud_image_file_id

#}

