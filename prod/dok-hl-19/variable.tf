variable "lxc-vars"  {
    type = object({
    ct_datastore_template_location      = string 
    ct_datastore_storage_location       = string
    ct_source_file_path                 = string
    node_name                           = string
    hostname                            = string
    dns_domain                          = string
    os_type                             = string
    time_zone                           = string
    sockets                             = string
    cores                               = number
    memory                              = number
    ballon                              = number 
    disksize                            = number
    vga                                 = string
    })
    default = {
    ct_datastore_template_location      = "local"
    ct_datastore_storage_location       = "cvm"
    ct_source_file_path                 = "http://download.proxmox.com/images/system/debian-12-standard_12.2-1_amd64.tar.zst" 
    node_name                           = "pve11"
    hostname                            = "dck-hl-33"
    dns_domain                          = "int.d3adc3ii.cc"
    os_type                             = "debian"
    time_zone                           ="Asia/Singapore"
    sockets                             = 1
    cores                               = 2
    memory                              = 2048
    ballon                              =  0 
    disksize                            = 10 
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
    vlan_id   = 2
    ipv4      = "192.168.2.33/24"
    subnet    = "255.255.255.0"
    bridge    = "vmbr0"
    gateway   = "192.168.2.10" 
    dns       = "192.168.2.10"
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

