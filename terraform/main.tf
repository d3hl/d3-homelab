module "komodo" {
  source = "./modules/komodo"
  virtual_environment_endpoint = var.virtual_environment_endpoint
  virtual_environment_api_token = var.virtual_environment_api_token
  virtual_environment_username = var.virtual_environment_username

}
