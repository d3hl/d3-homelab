variable "lxc-common" {
  type=object({
    node_name = string
    vm_id = number
    hostname = string
    cores = number 
    disk = number
    memory = number
    ipv4 = string
  })
  default = {
    node_name = ""
    vm_id = null
    hostname = ""
    cores = null 
    disk = null
    memory = null
    ipv4 = ""
  }
  }
  variable "publickey" {
    type=list()
  }