locals {
  os_type                        ="l26"
  datastore_id                   = "zvm"
  ct_datastore_template_location = "local"
  ct_datastore_storage_location  = "local"
  ct_source_file_path            = "http://download.proxmox.com/images/system/debian-12-standard_12.2-1_amd64.tar.zst"
  dns                            = ["192.168.2.10"]
  gateway                        = "192.168.2.1"
  cluster_name                   = "d3cluster"
  bridge                      = "vmbr0"
  cp_cores                          = 2 
  wk_cores                          = 4 
  disk                           = 10
  memory                         = 4096

}
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

variable "pvepassword" {}
variable "pveuser" {}
variable "vm_user" {}
variable "api_token" {}
variable "endpoint" {}


variable "talos_ips" {
  type=map(string)
  default = {
    talos_cp_1_ip_addr = ""
    talos_wk_1_ip_addr = ""
  }
  
  }