variable "virtual_environment_endpoint" {
  description = "Proxmox API endpoint URL (e.g. https://10.10.10.10:8006/)"
  type        = string
}

variable "virtual_environment_api_token" {
  description = "Proxmox API token (format: user@realm!tokenid=secret)"
  type        = string
  sensitive   = true
}

variable "virtual_environment_username" {
  description = "Username for Proxmox SSH operations"
  type        = string
  default     = "d3"
}

variable "ssh_public_key_file" {
  description = "Path to the SSH public key injected into VMs via cloud-init"
  type        = string
  default     = "/home/d3/.ssh/d3_tf.pub"
}

variable "virtual_environment_node_name" {
  description = "Default Proxmox node for this workspace (nodeD)"
  type        = string
  default     = "nodeD"
}

variable "virtual_environment_node_nodeA" {
  description = "Proxmox node A — used for VMs pinned to nodeA"
  type        = string
  default     = "nodeA"
}

variable "virtual_environment_node_nodeB" {
  description = "Proxmox node A — used for VMs pinned to nodeA"
  type        = string
  default     = "nodeB"
}
variable "virtual_environment_node_nodeF" {
  description = "Proxmox node F — used for VMs pinned to nodeF"
  type        = string
  default     = "nodeF"
}

variable "datastore_id" {
  description = "Datastore for VM disks (Ceph RBD)"
  type        = string
  default     = "cephVM"
}

variable "cfs_datastore_id" {
  description = "Datastore for cloud-init snippets and disk image imports (shared CephFS)"
  type        = string
  default     = "cFS"
}

variable "ubuntu_template_vm_id" {
  description = "VM ID assigned to the Ubuntu template; cloned by all workspace VMs"
  type        = number
  default     = 9999
}
