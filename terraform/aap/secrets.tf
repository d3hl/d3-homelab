# Reads Proxmox API credentials from 1Password.
# Expected item structure (Login category):
#   Title    : var.op_proxmox_item  (default: "proxmox_env")
#   URL      : https://10.10.10.10:8006/
#   Password : terraform@pve!tf-token=<secret>   (full token string)
ephemeral "onepassword_item" "proxmox" {
  vault = var.op_vault
  uuid  = gcqkndemtvypm5725liriyadhi
}

