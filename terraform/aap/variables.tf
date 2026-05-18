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

variable "virtual_environment_node_name" {
  description = "Proxmox node to deploy the AAP VM on"
  type        = string
  default     = "nodeD"
}

variable "datastore_id" {
  description = "Datastore for the VM disk (Ceph RBD)"
  type        = string
  default     = "cephVM"
}

variable "cfs_datastore_id" {
  description = "Datastore for cloud-init snippets (shared CephFS)"
  type        = string
  default     = "cFS"
}

# Create a RHEL 10 cloud-init template in Proxmox and set this to its VM ID.
variable "rhel10_template_vm_id" {
  description = "VM ID of the RHEL 10 cloud-init template to clone from"
  type        = number
  default     = 99999
}

variable "rhel10_template_node" {
  description = "Proxmox node where the RHEL 10 template resides"
  type        = string
  default     = "nodeF"
}

variable "aap_ip" {
  description = "Static IP/prefix for the AAP 2.6 containerized all-in-one VM (CIDR notation)"
  type        = string
  default     = "10.10.10.60/24"
}

variable "network_gateway" {
  description = "Default gateway for the AAP VM"
  type        = string
  default     = "10.10.10.1"
}

variable "network_bridge" {
  description = "Proxmox bridge for the AAP VM"
  type        = string
  default     = "vmbr0"
}

variable "network_vlan_tag" {
  description = "VLAN tag; null for untagged traffic"
  type        = number
  default     = null
}

# AAP 2.6 containerized all-in-one host for gateway, controller, hub, EDA, and database.
# Keep this above the small-test minimum; hub image cache and execution environments grow quickly.
variable "aap_cores" {
  description = "vCPU count for the AAP 2.6 containerized all-in-one VM"
  type        = number
  default     = 8
}

variable "aap_memory" {
  description = "RAM in MiB for the AAP 2.6 containerized all-in-one VM"
  type        = number
  default     = 24576
}

variable "aap_disk_size" {
  description = "Root disk size in GiB for RHEL 10, AAP containers, execution environments, and hub image cache"
  type        = number
  default     = 160
}

variable "aap_dns_domain" {
  description = "Internal DNS domain for the AAP VM FQDN"
  type        = string
  default     = "d3hl.site"
}
