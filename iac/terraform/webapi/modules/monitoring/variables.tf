variable "resource_group_name" {
  description = "Location of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group."
  type        = string
}

variable "diagnostics_settings_name" {

}

variable "resource_id" {

}

variable "law_id" {

}
variable "retention_days" {
  default = 30
}



variable "log_categories_retention" {
  type = map(object({
    enabled = bool
  }))

}
