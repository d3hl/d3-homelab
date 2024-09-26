variable "d3-pve-credentials" {
    type=object({
      endpoint     = string
      pve_user     = string
      pve_password = string
      publickey = string 
    })
    default = {
      endpoint     = ""
      pve_user     = ""
      pve_password = ""
      publickey = ""
    }
}