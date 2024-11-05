
variable "resource_group_name" {
  description = "Location of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group."
  type        = string
}

variable "tags" {
  type = map(string)
}

variable "key_vault_name" {
  description = "Name  of the key vault."
  type        = string
}

# variable "key_vault_id" {

# }
variable "user_assigned_identity_id" {

}

variable "service_principal_name" {

}

variable "service_principal_object_id" {

}
variable "tenant_id" {

}

variable "key_vault_sku" {
  type        = string
  description = "The SKU of the vault to be created."
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

