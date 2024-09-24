#module "lxc" {
#  source = "../../modules/lxc"
#}
variable "lxc_lxc-common" {
  
}
module "lxc" {
  source  = "app.terraform.io/ncdv-org/lxc/proxmox"
  version = "1.0.0"
  lxc-common = "${var.lxc_lxc-common}"
  node_name = "${var.lxc-common.node_name}"
  vm_id     = "${var.lxc-common.vm_id}" 
  cores     = "${var.lxc-common.cores}"
  disk      = "${var.lxc-common.disk}"
  memory    = "${var.lxc-common.memory}"
  ipv4      = "${var.lxc-common.ipv4}"
  ct_bridge = "${var.lxc-common.ct_bridge}"
}