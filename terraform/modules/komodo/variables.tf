variable "virtual_environment_endpoint" {
  type        = string
}

variable "virtual_environment_username" {
  description = "Proxmox User for API Access"
  type        = string
}

#variable "virtual_environment_password" {
#  description = "Password for Proxmox API User"
#  type        = string
#  sensitive   = true
#  default     = "don not use default passwords!"
#}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}
variable "virtual_environment_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve10"
}
variable "virtual_environment_node1_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve10"
}
variable "virtual_environment_node2_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve11"
}
variable "virtual_environment_node3_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve14"
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
variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks"
  default     = "cVM"
}
variable "ssh_public_key" {
  type = string
  sensitive = true
}