# Define the location of the resource group
resource_group_location = "eastus"  # Update this value if needed

# Define the name of the resource group
resource_group_name     = "rg-edusync-dev"  # Update this value if needed

environment             = "dev"  # Update this value if needed

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
sku      = "Standard"
