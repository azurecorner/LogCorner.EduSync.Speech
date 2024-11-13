# Define the location of the resource group
resource_group_location = "eastus"  # Update this value if needed

# Define the name of the resource group
resource_group_name     = "rg-edusync-dev"  # Update this value if needed

environment             = "dev"  # Update this value if needed
service_principal_name           = "BICEP-SP"
user_assigned_identity_name= "edusync-dev-identity"
# Define the name of the AKS cluster
aks_name                = "aks-edusync-dev"  # Update this value if needed

# Set the initial number of nodes for the node pool
node_count              = 3  # Update this value if needed

# Set the Managed Service Identity ID (null if not set)
msi_id                  = null  # Update this with the MSI ID if using one

# Define the admin username for the AKS cluster
username                = "azureadmin"  # Update this value if needed

# Specify the Load Balancer SKU
load_balancer_sku       = "standard"  # Update this value if needed

# Define the size of the Virtual Machine for the nodes
vm_size                 = "Standard_D2_v2"  # Update this value if needed

# Define the default tags for the resources
default_tags = {
  environment = "test"
  deployed_by = "terraform"
}

# Define the container registry details
acr_name = "locornermsacrdev"

# Define the app service plan details
sku      = "Standard"

# Define the key vault details
key_vault_name = "kv-shared-edusync-dev"

# Define the key vault SKU
key_vault_sku  = "standard"


// sql server
mssql_server_name                                           = "mssql-server-edusync-dev"
mssql_server_version                                        = "12.0"
mssql_database_read_scale                                   = true
mssql_database_sku_name                                     = "BC_Gen5_2"
mssql_database_storage_account_type                         = "Geo"
mssql_database_zone_redundant                               = true
mssql_database_long_term_retention_policy_monthly_retention = "P1M"
mssql_database_long_term_retention_policy_week_of_year      = 1
sql_db_name                                                 = "backend-db-edusync-dev"
admin_username                                              = "mssql-admin-user"




// web application gateway

application_gateway_name = "appgw-brooklyn-dev"

application_gateway_backend_pool_name = "appgw-brooklyn-dev-pool"

application_gateway_backend_settings_name = "appgw-brooklyn-dev-https-settings"

application_gateway_probe_name = "appgw-brooklyn-dev-https-probe"

application_gateway_https_frontend_port = "appgw-brooklyn-dev-https-frontend-port"

frontend_ip_configuration_name = "appgw-frontend-ip"

https_listener_name = "https-listener"

ssl_certificate_name = "loreal-neo-cert"

gateway_ip_configuration_name = "app-gateway-ip-configuration"
