variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_username" {
  description = "Proxmox User for API Access"
  type        = string
}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}

variable "virtual_environment_pve10_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve10"
}
variable "virtual_environment_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeD"
}
variable "virtual_environment_nodeA_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeA"
}
variable "virtual_environment_nodeB_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeB"
}
variable "virtual_environment_nodeC_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeC"
}

