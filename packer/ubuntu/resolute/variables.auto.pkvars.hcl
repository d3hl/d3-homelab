
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
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
