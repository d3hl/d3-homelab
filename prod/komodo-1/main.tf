module "vm" {
  source  = "app.terraform.io/d3-org/vm/pve"
  version = "1.0.6"
  virtual_environment_api_token = "${var.virtual_environment_api_token}"
  virtual_environment_endpoint = "${var.virtual_environment_endpoint}"
  virtual_environment_node_name = "pve10"
  virtual_environment_ssh_username = "d3"
  virtual_environment_storage = "cephfs"
  virtual_environment_username = "root@pam"
}