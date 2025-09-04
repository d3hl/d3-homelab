module "vm" {
  source  = "app.terraform.io/d3-org/vm/pve"
  version = "1.0.3"
   virtual_environment_endpoint=var.virtual_environment_endpoint
   virtual_environment_api_token=var.virtual_environment_api_token
  
}
module "vm" {
  source  = "app.terraform.io/d3-org/vm/pve"
  version = "1.0.3"

  virtual_environment_api_token = "${var.vm_virtual_environment_api_token}"
  virtual_environment_endpoint = "${var.vm_virtual_environment_endpoint}" 
}