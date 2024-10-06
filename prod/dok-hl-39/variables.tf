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
    vm_id = null
    hostname = ""
    cores = null 
    disk = null
    memory = null
    ipv4 = ""
    ct_bridge = ""
  }
  }
variable "pvepassword" {}
variable "pveuser" {}
variable "api_token" {}
variable "endpoint" {}
variable "vm_user" {}