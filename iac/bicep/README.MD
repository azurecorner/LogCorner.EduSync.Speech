$resourceGroupName="RG-EVENT-DRIVEN-ARCHITECTURE"

New-AzResourceGroupDeployment `
  -Name "datasynchro-sre-agent" `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile main.bicep `
  -TemplateParameterFile main.bicepparam `
  -DeploymentDebugLogLevel All



  # https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster?source=recommendations

  # https://learn.microsoft.com/en-us/samples/azure-samples/aks-application-gateway-for-containers-bicep/aks-application-gateway-for-containers-bicep/



  # application gateway for container


  az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.NetworkFunction
az provider register --namespace Microsoft.ServiceNetworking

# Install Azure CLI extensions.
az extension add --name alb