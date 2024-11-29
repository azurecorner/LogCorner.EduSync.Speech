terraform init -var-file="workspaces/dev.tfvars"
terraform plan -var-file="workspaces/dev.tfvars"
terraform apply -var-file="workspaces/dev.tfvars" --auto-approve



terraform plan -out main.tfplan

terraform apply main.tfplan

aztfexport resource-group 'rg-edusync-dev'


$AppGw = Get-AzApplicationGateway -Name appgw-edusync-dev-001 -ResourceGroupName rg-edusync-dev
Stop-AzApplicationGateway -ApplicationGateway $AppGw



$AppGw = Get-AzApplicationGateway -Name appgw-edusync-dev-001 -ResourceGroupName rg-edusync-dev
Start-AzApplicationGateway -ApplicationGateway $AppGw



# Managed DevOps Pools: Simplifying Azure DevOps Setup =>   https://xebia.com/blog/microsoft-services-managed-devops-pools-simplifying-azure-devops-setup/