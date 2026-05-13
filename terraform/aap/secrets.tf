# op://d3HL/proxmox_env
# Expected item structure (Login category):
#   URL      → proxmox provider endpoint
#   Password → terraform@pve!tf-token=<secret>  (full API token string)
data "onepassword_item" "proxmox" {
  vault = "d3HL"
  title = "proxmox_env"
}

