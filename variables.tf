variable "project_name" {
  type        = string
  default     = "ncdv-hl"
}

variable "workspace" {
  type        = string
  default     = "d3-homelab"
}
variable "resource_tags" {
  type        = map(string)
  default     = { } 
}


variable "endpoint" {}
variable "pvepassword" {}
variable "pveuser" {}
variable "vm_user" {}
variable "api_token" {}
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

variable "talos-common" {
  type=object({
    node_name = string
    cluster_name = string
    vm_id = number
    cp_cores = number 
    wk_cores = number 
    memory = number
  })
  default = {
    node_name = ""
    cluster_name = ""
    vm_id = null
    cp_cores = null 
    wk_cores = null 
    memory = null
  }
}

variable "talos_ips" {
  type=map(string)
  default = {
    talos_cp_01_ip_addr = ""
    talos_wk_01_ip_addr = ""
  }
  
  }