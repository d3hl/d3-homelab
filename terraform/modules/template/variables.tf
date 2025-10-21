variable "virtual_environment_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeA"
}
variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks"
  default     = "cephVM"
}
