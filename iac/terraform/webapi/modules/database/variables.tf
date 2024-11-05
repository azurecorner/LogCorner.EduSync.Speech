
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

variable "sql_db_name" {
  type        = string
  description = "The name of the SQL Database."
}

variable "admin_username" {
  type        = string
  description = "The administrator username of the SQL logical server."

}


variable "mssql_server_name" {

}

variable "mssql_server_version" {

}
variable "mssql_database_read_scale" {

}
variable "mssql_database_sku_name" {

}
variable "mssql_database_storage_account_type" {

}

variable "mssql_database_zone_redundant" {

}

variable "mssql_database_long_term_retention_policy_monthly_retention" {

}

variable "mssql_database_long_term_retention_policy_week_of_year" {

}

variable "key_vault_id" {

}

