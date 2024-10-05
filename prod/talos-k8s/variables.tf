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
    cp_cores = null 
    wk_cores = null 
    memory = null
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