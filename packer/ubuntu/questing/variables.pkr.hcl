variable "proxmox_api_url" {
    type = string
    default = "https://10.10.10.10:8006"
}

variable "proxmox_api_token_id" {
    type = string
    default = "root@pam!tf"
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
    default = "43c76fd0-acdd-4d25-863c-23366c1028c7"
    
}

variable "ssh_authorized_keys" {
  type      = list(string)
  sensitive = true
}