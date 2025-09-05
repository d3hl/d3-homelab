module "komodo-1" {
  #source  = "app.terraform.io/d3-org/vm/pve"
  source  = "./resources/komodo-1"
  virtual_environment_endpoint = "${var.virtual_environment_endpoint}"
  virtual_environment_api_token = "${var.virtual_environment_api_token}"
  virtual_environment_node_name = "${var.virtual_environment_node_name}"
  }