variable "virtual_environment_endpoint" {
  type        = string
  description = "The endpoint for the Proxmox Virtual Environment API (example: https://host:port)"
}

variable "virtual_environment_password" {
  type        = string
  description = "The password for the Proxmox Virtual Environment API"
}

variable "virtual_environment_username" {
  type        = string
  description = "The username and realm for the Proxmox Virtual Environment API (example: root@pam)"
}

variable "virtual_environment_endpoint" {
  description = "The endpoint for the Proxmox Virtual Environment API (example: https://host:port)"
  type        = string
}

variable "virtual_environment_username" {
  description = "Proxmox User for API Access"
  type        = string
  default     = "root@pam"
}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}

variable "virtual_environment_ssh_username" {
  description = "The username for the Proxmox Virtual Environment API"
  type        = string
  default     = "root"
}

variable "virtual_environment_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve"
}

variable "virtual_environment_insecure" {
  description = "Self Signed Certificates Used"
  type        = bool
  default     = true
}

variable "virtual_environment_storage" {
  description = "Name of the Proxmox storage"
  type        = string
  default     = "cephfs"
}