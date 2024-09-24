variable "project_name" {
  type        = string
  default     = "ncdv-hl"
}

variable "workspace" {
  type        = string
  default     = "d3-homelab"
}
variable "resource_tags" {
  type        = map(string)
  default     = { } 
}

variable "lxc-common" {
  type=object({
    node_name = string
    vm_id = number
    cores = number 
    disk = number
    memory = number
    ipv4 = string
    ct_bridge = string
  })
  default = {
    node_name = ""
    vm_id = ""
    cores = "" 
    disk = ""
    memory = ""
    ipv4 = ""
    ct_bridge = ""
  }
}
locals {
  os_type = "debian"
  ct_datastore_template_location = "local"
  ct_datastore_storage_location  = "local"
  ct_source_file_path            = "http://download.proxmox.com/images/system/debian-12-standard_12.2-1_amd64.tar.zst"
  dns                            = ["192.168.2.10","192.168.2.1"]
  gateway                        = "192.168.2.1"
}