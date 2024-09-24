variable "lxc-common" {
  type=object({
    node_name = string
    vm_id = number
    cores = number 
    disk = number
    memory = number
    os_type = string
    dns = list()
    ipv4 = string
    gateway = string
    ct_bridge = number
  })
  default = {
    node_name = ""
    vm_id = ""
    cores = "" 
    disk = ""
    memory = ""
    os_type = ""
    dns = ""
    ipv4 = ""
    gateway = ""
    ct_bridge = ""
    
  }
}
locals {
  
}