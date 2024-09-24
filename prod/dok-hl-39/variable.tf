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
}