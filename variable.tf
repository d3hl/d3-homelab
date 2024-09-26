variable "d3-pve-credentials" {
    type=object({
      endpoint     = string
      pve_user     = string
      pve_password = string 
    })
    default = {
      endpoint     = ""
      pve_user     = ""
      pve_password = ""
    }
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
    vm_id     = {}
    cores     = {} 
    disk      = {}
    memory    = {}
    ipv4      = ""
    ct_bridge = "" 
  }
}