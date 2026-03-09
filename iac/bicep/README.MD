$resourceGroupName="RG-EVENT-DRIVEN-ARCHITECTURE"

New-AzResourceGroupDeployment `
  -Name "DATASYNCHRO-EVENT-DRIVEN" `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile main.bicep `
  -TemplateParameterFile main.bicepparam `
  -DeploymentDebugLogLevel All

# https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/how-to-connect-role-based-access-control?pivots=azure-cli#permission-model

#  Using Managed Identities to authenticate with Azure Cosmos DB => https://dev.to/willvelida/using-managed-identities-to-authenticate-with-azure-cosmos-db-23ga

# https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster?source=recommendations

# https://learn.microsoft.com/en-us/samples/azure-samples/aks-application-gateway-for-containers-bicep/aks-application-gateway-for-containers-bicep/

# https://github.com/Azure-Samples/aks-managed-prometheus-and-grafana-bicep/tree/main

# application gateway for container

az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.NetworkFunction
az provider register --namespace Microsoft.ServiceNetworking

# Install Azure CLI extensions.
az extension add --name alb


# LogCorner.EduSync
Building microservices through Event Driven Architecture

# signalrhub
kubectl apply -f namespace.yaml
kubectl apply -f signalrhub.yaml
kubectl apply -f curl-test.yaml

kubectl exec -it curl-test -n azure-workloads --   curl -v -k http://signalr-service/logcornerhub  

# webapi
kubectl apply -f workload-identity-service-account.yaml
kubectl apply -f webapi.yaml

kubectl get pods -n azure-workloads
kubectl  rollout restart deployment -n azure-workloads


kubectl get pods -n azure-workloads
kubectl get svc -n azure-workloads


kubectl logs web-frontend-app-84bb97d577-mj9gp -n azure-workloads

kubectl exec -it curl-test -n azure-workloads -- `
  curl -v -k -X POST http://webapi-service/api/speech `
  -H "Content-Type: application/json" `
  -d "{
    `"title`": `"this is a title`",
    `"description`": `"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.`",
    `"url`": `"http://test.com`",
    `"typeId`": 1
  }"


# broker service
kubectl apply -f workload-identity-service-account.yaml
kubectl apply -f broker.yaml

kubectl get pods -n azure-workloads

# web api query

kubectl apply -f webapi-query.yaml

kubectl get pods -n azure-workloads


kubectl logs web-api-64d6f78cc5-ps27k -n azure-workloads


kubectl exec -it curl-test -n azure-workloads --   curl -v -k -X GET http://web-api-query-service/api/speech 

# web app front

kubectl apply -f webapp.yaml

kubectl get pods -n azure-workloads


kubectl logs web-api-64d6f78cc5-ps27k -n azure-workloads


kubectl exec -it curl-test -n azure-workloads --   curl -v -k -X GET http://web-api-query-service/api/speech 

kubectl  rollout restart deployment -n azure-workloads