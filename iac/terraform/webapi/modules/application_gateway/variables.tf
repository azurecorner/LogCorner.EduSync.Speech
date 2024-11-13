
variable "resource_group_name" {
  description = "Location of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group."
  type        = string
}

variable "virtual_network_subnet_id" {
  description = "Id of the web application subnet"
  type        = string
}

variable "tags" {
  type = map(string)
}

variable "key_vault_secret_id" {
  description = "Id  of the secret of the application gateway in the keyvault."
  type        = string
}

variable "user_assigned_identity_id" {
  description = "id of the user assigned managed identity."
  type        = string
}
variable "functionapp_backend_address_pool_fqdn" {

}

variable "public_ip_address_id" {

}

variable "application_gateway_name" {

}

variable "application_gateway_backend_pool_name" {

}

variable "application_gateway_backend_settings_name" {

}

variable "application_gateway_probe_name" {

}


variable "application_gateway_https_frontend_port" {

}
variable "frontend_ip_configuration_name" {

}

variable "https_listener_name" {

}

variable "ssl_certificate_name" {

}

variable "gateway_ip_configuration_name" {

}