
variable "resource_group_name" {
  description = "Location of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the network security group"
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(string)
}
variable "network_security_group_name" {

}

variable "nsgrules" {
  type = map(any)
}
