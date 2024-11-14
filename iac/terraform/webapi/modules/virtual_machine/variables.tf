variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "subnet_id" {
  type = string
}

variable "username" {
  default = "logcorner"
}

variable "public_ip_name" {
  type = string
}

variable "network_security_group_name" {
  type = string
}

variable "network_interface_name" {
  type = string
}

variable "virtual_machine_name" {
  type = string
}

variable "computer_name" {
  type = string
}

