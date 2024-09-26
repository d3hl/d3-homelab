variable "lxc-common" {
  type=object({
    node_name = string
    vm_id = number
    hostname = string
    cores = number 
    disk = number
    memory = number
    ipv4 = string
    ct_bridge = string
  })
  default = {
    node_name = ""
    vm_id = 0
    hostname = ""
    cores = 0 
    disk = 0
    memory = 0
    ipv4 = ""
    ct_bridge = ""
  }
  }
variable "d3-pve-credentials" {
    type=object({
      endpoint     = string
      pve_user     = string
      pve_password = string
      publickey = string 
    })
    default = {
      endpoint     = ""
      pve_user     = ""
      pve_password = ""
      publickey = ""
    }
}