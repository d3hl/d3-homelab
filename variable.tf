variable "credentials" {
    type = object({
        endpoint = var.endpoint
        username = var.pve_user
        password = var.pve_password
        #api_token = var.pve_api_token
    })
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t2.micro"
}

variable "instance_name" {
  description = "EC2 instance name"
  default     = "Provisioned by Terraform"
}