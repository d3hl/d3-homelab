

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "ncdv-hl"
}

variable "workspace" {
  description = "Name of the workspace."
  type        = string
  default     = "d3-homelab"
}
variable "resource_tags" {
  description = "Name of all resources."
  type        = map(string)
  default     = { } 
}


