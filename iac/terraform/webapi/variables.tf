variable "resource_group_name" {
  type        = string
  description = "Location of the azure resource group."
}
variable "resource_group_location" {
  type        = string
  description = "Location of the azure resource group."
}

variable "environment" {
  type        = string
  description = "Name of the deployment environment"
}

variable "default_tags" {
  type = object({
    environment = string
    deployed_by = string
  })
  description = "A map of tags to assign to the resources."
}


variable "user_assigned_identity_name" {
  type        = string
  description = "The name of the user assigned identity."

}

variable "service_principal_name" {
  type        = string
  description = "The name of the service principal."

}

#---------------   azure kubernetes services ----------------------------------------
variable "aks_name" {
  type        = string
  description = "Location of the azure resource group."
}

variable "node_count" {
  type        = string
  description = "The number of K8S nodes to provision."
}
variable "username" {
  type        = string
  description = "The admin username for the new cluster."

}

variable "load_balancer_sku" {
  type        = string
  description = "The SKU of the Load Balancer."

}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine."


}
variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."

}

#---------------   azure container registry ----------------------------------------
variable "acr_name" {

}

variable "sku" {

}
#---------------   azure key vault ----------------------------------------
variable "key_vault_name" {
  description = "Name  of the key vault."
  type        = string
}

variable "key_vault_sku" {
  type        = string
  description = "The SKU of the vault to be created."
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}
