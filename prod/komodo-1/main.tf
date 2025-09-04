module "vm" {
  source  = "app.terraform.io/d3-org/vm/pve"
  version = "1.0.6"
  virtual_environment_api_token = "${var.vm_virtual_environment_api_token}"
  virtual_environment_endpoint = "${var.vm_virtual_environment_endpoint}"
  virtual_environment_node_name = "true"
  virtual_environment_ssh_username = "d3"
  virtual_environment_storage = "cephfs"
  virtual_environment_username = "root@pam"
}