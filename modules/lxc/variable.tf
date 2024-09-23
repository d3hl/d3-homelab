variable "lxc-vars"  {
    type = object({
    dns_domain                          = string
    os_type                             = string
    time_zone                           = string
    sockets                             = string
    memory                              = number
    ballon                              = number 
    vga                                 = string
    })
}

variable "network" {
    type = object({
    vlan_id   = number
    subnet    = string
    bridge    = string
    gateway   = string 
    dns       = string
  })
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


