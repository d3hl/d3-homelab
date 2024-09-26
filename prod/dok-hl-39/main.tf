terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.65.0"
    }
  }
}


module "pve" {
  source  = "app.terraform.io/ncdv-org/pve/d3"
  version = "1.0.0"
  cores = "${var.pve_lxc-common.cores}"
  ct_bridge = "${var.pve_lxc-common.ct_bridge}"
  disk = "${var.pve_lxc-common.disk}"
  ipv4 = "${var.pve_lxc-common.ipv4}"
  memory = "${var.pve_lxc-common.memory}"

}