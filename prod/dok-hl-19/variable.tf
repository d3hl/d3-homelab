variable "lxc-vars"  {
    type = object({
    dns_domain                          = string
    os_type                             = string
    time_zone                           = string
    sockets                             = string
    ballon                              = number 
    vga                                 = string
    })
    default = {
    dns_domain                          = "int.d3adc3ii.cc"
    os_type                             = "debian"
    time_zone                           = "Asia/Singapore"
    sockets                             = 1
    ballon                              = 0 
    vga                                 = "std"
    }
}
variable "network" {
    type = object({
    vlan_id   = number
    subnet    = string
    bridge    = string
    gateway   = string
    dns       = string
  })
  default = {
    vlan_id = 2
    subnet  = "255.255.255.0"
    bridge  = "vmbr0"
    gateway = "192.168.2.1" 
    dns     = "192.168.2.10"
  }
}

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "ncdv-hl"
}

variable "workspace" {
  description = "Name of the workspace."
  type        = string
  default     = "d3-homelab"
}
variable "resource_tags" {
  description = "Name of all resources."
  type        = map(string)
  default     = { } 
}

