module "komodo" {
  source = "./modules/resources/komodo"
  virtual_environment_endpoint = var.virtual_environment_endpoint
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_username = var.virtual_environment_username

}

#module "Supermicro" {
 # source = "./modules/Supermicro"
  #virtual_environment_endpoint = var.virtual_environment_endpoint
  #virtual_environment_api_token = var.virtual_environment_api_token
  #virtual_environment_username = var.virtual_environment_username
  # pass the debian cloud image file id exported by the komodo module
  #debian_cloud_image_file_id = module.komodo.debian_cloud_image_file_id

#}

