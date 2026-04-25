
variable "proxmox_api_url" {
    type = strinig
    default = "https://10.10.10.10:8006/api2/json"
}

variable "proxmox_api_token_id" {
    type = string
    default = "root@pam!tf"
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
    
}

variable "ssh_authorized_keys" {
    type      = list(string)
    sensitive = true
    default   = []
}
