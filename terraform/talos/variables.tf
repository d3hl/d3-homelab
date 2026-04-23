variable "virtual_environment_endpoint" {
  type        = string
  description = "Proxmox API endpoint URL"
}

variable "virtual_environment_api_token" {
  type        = string
  sensitive   = true
  description = "Proxmox API token"
}

variable "virtual_environment_username" {
  type        = string
  description = "Username for Proxmox SSH operations"
  default     = "d3"
}

variable "datastore_id" {
  type        = string
  description = "Proxmox datastore for VM disks"
  default     = "cephVM"
}

variable "iso_datastore_id" {
  type        = string
  description = "Proxmox datastore for ISO files"
  default     = "cFS"
}

variable "iso_node" {
  type        = string
  description = "Proxmox node to upload the Talos ISO to"
  default     = "nodeA"
}

variable "talos_version" {
  type        = string
  description = "Talos Linux version to deploy"
  default     = "v1.9.5"
}

variable "cluster_name" {
  type        = string
  description = "Name of the Talos Kubernetes cluster"
  default     = "talos-homelab"
}

# The cluster endpoint is the address of the first control plane (or a VIP).
# All kubeconfig and talosconfig files will point to this address.
variable "cluster_endpoint" {
  type        = string
  description = "Kubernetes API endpoint — IP of the first control plane or a VIP (https://<IP>:6443)"
  default     = "https://10.10.10.40:6443"
}

variable "gateway" {
  type        = string
  description = "Default gateway for Talos nodes"
  default     = "10.10.10.1"
}

variable "subnet_prefix" {
  type        = string
  description = "Subnet prefix length for node IPs (e.g. 24 for /24)"
  default     = "24"
}

variable "nameservers" {
  type        = list(string)
  description = "DNS nameservers injected into Talos machine configs"
  default     = ["1.1.1.1", "8.8.8.8"]
}

# Network interface name inside the Talos VM.
# q35 + virtio: first NIC is typically "enp6s18"
# i440fx + virtio: typically "eth0"
variable "network_interface" {
  type        = string
  description = "NIC name inside Talos VMs (enp6s18 for q35, eth0 for i440fx)"
  default     = "enp6s18"
}

# Map of control plane node name → { Proxmox node, static IP }.
# IPs must be reachable before talos_machine_configuration_apply runs.
# Set up DHCP reservations matching these IPs, or ensure they are available.
variable "controlplane_nodes" {
  type = map(object({
    pve_node = string
    ip       = string
  }))
  description = "Control plane nodes: name → { pve_node, ip }"
  default = {
    talos-cp-1 = { pve_node = "nodeA", ip = "10.10.10.40" }
    talos-cp-2 = { pve_node = "nodeB", ip = "10.10.10.41" }
  }
}

variable "worker_nodes" {
  type = map(object({
    pve_node = string
    ip       = string
  }))
  description = "Worker nodes: name → { pve_node, ip }"
  default = {
    talos-worker-1 = { pve_node = "nodeA", ip = "10.10.10.42" }
    talos-worker-2 = { pve_node = "nodeB", ip = "10.10.10.43" }
  }
}

# IP of the control plane node used to bootstrap etcd.
# Must be one of the IPs in controlplane_nodes.
variable "bootstrap_ip" {
  type        = string
  description = "IP of the control plane node that bootstraps etcd"
  default     = "10.10.10.40"
}

variable "controlplane_cpu_cores" {
  type        = number
  description = "vCPU cores for control plane nodes"
  default     = 2
}

variable "controlplane_memory_mb" {
  type        = number
  description = "Memory (MB) for control plane nodes"
  default     = 4096
}

variable "controlplane_disk_size_gb" {
  type        = number
  description = "Disk size (GB) for control plane nodes"
  default     = 50
}

variable "worker_cpu_cores" {
  type        = number
  description = "vCPU cores for worker nodes"
  default     = 2
}

variable "worker_memory_mb" {
  type        = number
  description = "Memory (MB) for worker nodes"
  default     = 4096
}

variable "worker_disk_size_gb" {
  type        = number
  description = "Disk size (GB) for worker nodes"
  default     = 50
}

variable "allow_scheduling_on_controlplanes" {
  type        = bool
  description = "Allow workload scheduling on control plane nodes"
  default     = false
}
