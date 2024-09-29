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


variable "endpoint" {
  default = "https://192.168.2.11:8006/"
}
variable "pvepassword" {}
variable "pveuser" {}
variable "api_token" {}
variable "lxc-common" {
  type=object({
    node_name = string
    hostname = string
    cores = number 
    disk = number
    memory = number
    ipv4 = string
    vm_id = number
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