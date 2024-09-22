
module "lxc" {
  source = "./modules/lxc"
  lxc-vars = var.lxc-vars
  network = var.network
}

locals {
  required_tags = {
    project     = var.project_name,
    workspace   = var.workspace,
  }
  tags = merge(var.resource_tags, local.required_tags)
}