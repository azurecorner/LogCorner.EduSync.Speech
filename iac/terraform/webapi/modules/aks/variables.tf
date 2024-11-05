variable "resource_group_location" {
  type        = string
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string

  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}


variable "aks_name" {
  type        = string

  description = "Location of the azure resource group."
}

variable "subnet_aks_id" {
  type        = string
  description = "The ID of the subnet to use for the AKS cluster."

}


variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."

}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."

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

variable "default_tags" {
  type = object({
    environment = string
    deployed_by = string
  })
  default = {
    environment = ""
    deployed_by = ""
  }
}

variable "tags" {

}