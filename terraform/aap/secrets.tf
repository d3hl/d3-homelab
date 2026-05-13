# Reads Proxmox API credentials from 1Password.
# Expected item structure (Login category):
#   Title    : var.op_proxmox_item  (default: "proxmox_env")
#   URL      : https://10.10.10.10:8006/
#   Password : terraform@pve!tf-token=<secret>   (full token string)
data "onepassword_item" "proxmox" {
  vault = var.op_vault
  title = var.op_proxmox_item
}

# op://d3HLPRV/d3_ops/public key
data "onepassword_item" "d3_ops" {
  vault = "d3HLPRV"
  title = "d3_ops"
}
