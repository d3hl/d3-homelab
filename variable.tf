variable "credentials" {
    type = object({
        endpoint = string
        pve_user = string
        pve_password = string
        #api_token = var.pve_api_token
    })
}