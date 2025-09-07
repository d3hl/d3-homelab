variable "proxmox_pve_node_name" {
  type    = string
  default = "pve10"
}

variable "proxmox_pve_node_address" {
  type = string
}

variable "prefix" {
  type    = string
  default = "Win"
}

variable "username" {
  type    = string
  default = "d3"
}

variable "password" {
  type      = string
  sensitive = true
  # NB the password will be reset by the cloudbase-init SetUserPasswordPlugin plugin.
  # NB this value must meet the Windows password policy requirements.
  #    see https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements
  default = "mailabannhe"
}