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


#---------------   azure sql  server ----------------------------------------


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

variable "sql_db_name" {
  type        = string
  description = "The name of the SQL Database."
}

variable "admin_username" {
  type        = string
  description = "The administrator username of the SQL logical server."

}

variable "mssql_server_firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))

  default = {
    rule1 = {
      start_ip_address = "90.91.111.65"
      end_ip_address   = "90.91.111.65"
    }
    rule2 = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }
}


# api management



variable "query_http_api_service_url" {
  default = "https://conferenceapi.azurewebsites.net"
}

variable "command_http_api_service_url" {
  default = "http://10.10.1.35"
}

variable "virtual_network_name" {
  default = "apim-aks-vnet"
}

variable "subnet_id" {
  default = "apim-subnet"
}

variable "api_management_name" {
  default = "apim-edusync-dev-009"
}

variable "sku_name" {
  default = "Developer_1"
}

variable "publisher_name" {
  default = "logconer"
}

variable "publisher_email" {
  default = "tocane.techhnologies@gmail.com"
}

variable "nsgrules_apim" {
  description = "NSG rules for APIM"
  type        = map(any)
  default = {

    "Allow_HTTP" = {
      name                       = "Allow_HTTP"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

      "Allow_HTTPS" = {
      name                       = "Allow_HTTPS"
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    
    # TODO : use source as ApiManagement service tag and destination as Virtual Network service tag
    "Allow_APIM_Inbound" = {
      name                       = "Allow_APIM_Inbound"
      priority                   = 1004
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3443"
      source_address_prefix      = "ApiManagement"
      destination_address_prefix = "VirtualNetwork"
    }
      "Allow_APIM_Outbound" = {
      name                       = "Allow_APIM_Outbound"
      priority                   = 1005
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "ApiManagement"
    }
  }
}
variable "nsgrules_aks" {
  description = "NSG rules for AKS"
  type        = map(any)
  default = {
    "Allow_HTTP" = {
      name                       = "Allow_HTTP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

     "Allow_HTTPS" = {
      name                       = "Allow_HTTPS"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    # Add more rules as needed for AKS
  }
}

variable "nsgrules_vm" {
  description = "NSG rules for Virtual Machine"
  type        = map(any)
  default = {
    "Allow_RDP_Inbound" = {

      name                       = "Allow_RDP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

  }
}

//application gateway

variable "application_gateway_name" {

}

variable "application_gateway_backend_pool_name" {

}

variable "application_gateway_backend_settings_name" {

}

variable "application_gateway_probe_name" {

}
variable "gateway_ip_configuration_name" {
  
}
variable "application_gateway_https_frontend_port" {

}
variable "frontend_ip_configuration_name" {

}

variable "https_listener_name" {

}

variable "ssl_certificate_name" {

}




# virtual machine

variable "vm_username" {
  type = string
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