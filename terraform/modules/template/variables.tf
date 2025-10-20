variable "virtual_environment_pve10_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve10"
}
variable "virtual_environment_pve14_name" {
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
  default     = "cephVM"
}
