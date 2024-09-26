variable "lxc-common" {
  type=object({
    node_name = string
    vm_id = number
    cores = number 
    disksize = number
    memory = number
    ipv4 = string
    ct_bridge = string
  })
  default = {
    node_name = ""
    vm_id = 0
    cores = 0 
    disksize = 0
    memory = 0
    ipv4 = ""
    ct_bridge = ""
  }
  }
