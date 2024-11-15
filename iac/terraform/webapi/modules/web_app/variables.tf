
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

variable "virtual_network_subnet_id" {

}

variable "service_plan_name" {

}

variable "linux_web_app_name" {

}