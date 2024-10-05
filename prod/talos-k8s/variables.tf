variable "talos-common" {
  type=object({
    node_name = string
    cp_cores = number 
    wk_cores = number 
    memory = number
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

variable "pvepassword" {}
variable "pveuser" {}
variable "api_token" {}
variable "endpoint" {
  default = "https://192.168.2.11:8006/"
}


variable "talos_ips" {
  type=map(string)
  default = {
    talos_cp_01_ip_addr = ""
    talos_wk_01_ip_addr = ""
  }
  
  }