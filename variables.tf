variable "endpoint" {
  default = "https://192.168.2.11:8006/"
}
variable "pvepassword" {}
variable "pveuser" {}
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
    vm_id = number
  })
  default = {
    node_name = ""
    vm_id = 0
    hostname = ""
    cores = 0 
    disk = 0
    memory = 0
    ipv4 = ""
    vm_id = null
  }
  }

  variable "hostname" {
  type = string
  default = ""
}
variable "cores" {
  type = number
  default = null
}
variable "memory" {
  type = number
  default = null
}
variable "ipv4" {
  type = string
  default = ""
}
variable "ct_bridge" {
  type = string
  default = ""
}