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
  description = "Default Proxmox node for AAP VMs"
  type        = string
  default     = "nodeD"
}

variable "datastore_id" {
  description = "Datastore for VM disks (Ceph RBD)"
  type        = string
  default     = "cephVM"
}

variable "cfs_datastore_id" {
  description = "Datastore for cloud-init snippets (shared CephFS)"
  type        = string
  default     = "cFS"
}

# AAP requires RHEL 9 — create a RHEL 9 cloud-init template in Proxmox first,
# then set this to that template's VM ID.
variable "rhel9_template_vm_id" {
  description = "VM ID of the RHEL 9 cloud-init template to clone AAP VMs from"
  type        = number
}

variable "rhel9_template_node" {
  description = "Proxmox node where the RHEL 9 template resides"
  type        = string
  default     = "nodeF"
}

# Static IPs — reserve these in your router or DHCP server before applying.
variable "aap_gateway_ip" {
  description = "Static IP for aap-gateway (Platform Gateway)"
  type        = string
  default     = "10.10.10.50/24"
}

variable "aap_controller_ip" {
  description = "Static IP for aap-controller (Automation Controller)"
  type        = string
  default     = "10.10.10.51/24"
}

variable "aap_hub_ip" {
  description = "Static IP for aap-hub (Automation Hub)"
  type        = string
  default     = "10.10.10.52/24"
}

variable "aap_db_ip" {
  description = "Static IP for aap-db (External PostgreSQL)"
  type        = string
  default     = "10.10.10.53/24"
}

variable "network_gateway" {
  description = "Default gateway for all AAP VMs"
  type        = string
  default     = "10.10.10.1"
}
