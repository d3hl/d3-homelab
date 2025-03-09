variable "talos-common" {
  type=object({
    node_name = string
    cluster_name = string
    cp_cores = number 
    wk_cores = number 
    memory = number
    vm_id = number
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
    talos_cp_1_ip_addr = ""
    talos_wk_1_ip_addr = ""
  }
  }

variable "credentials" {
  type=object({
    endpoint =  string
    pveuser  =  string
    pvepassword = string
    api_token = string
  })
}




#variable "pvepassword" {}
#variable "pveuser" {}
#variable "vm_user" {}
#variable "api_token" {}
#variable "endpoint" {}
