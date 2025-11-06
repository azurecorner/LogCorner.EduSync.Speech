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


# LogCorner.EduSync
Building microservices through Event Driven Architecture

# Set the ACR name and log in
$acrName = "datasynchroacr"
$accessToken = az acr login --name $acrName --expose-token --output tsv --query accessToken

# Lancer docker login avec token
docker login "$acrName.azurecr.io" `
  --username "00000000-0000-0000-0000-000000000000" `
  --password $accessToken


 # Build and push the SignalR HUB image
docker build -t "$acrName.azurecr.io/signalr-hub:latest" -f .\src\Hub\LogCorner.EduSync.Notification.Server\Dockerfile .\src\ 
docker push "$acrName.azurecr.io/signalr-hub:latest"

# Build and push the Web API command image
docker build -t "$acrName.azurecr.io/web-api:latest" -f .\src\Command\LogCorner.EduSync.Speech.Presentation\Dockerfile .\src\ --no-cache
docker push "$acrName.azurecr.io/web-api:latest"



# Build and push the Broker Service image
docker build -t "$acrName.azurecr.io/broker-app:latest" -f .\src\broker\LogCorner.EduSync.Speech.WorkerService\Dockerfile .\src\ --no-cache
docker push "$acrName.azurecr.io/broker-app:latest"

C:\Users\logcorner\source\repos\LogCorner.EduSync.Speech.Command\src\broker\LogCorner.EduSync.Speech.WorkerService\Dockerfile


# Build and push the Web API query image
docker build -t "$acrName.azurecr.io/web-api-query:latest" -f .\src\Query\LogCorner.EduSync.Speech.Presentation\Dockerfile .\src\ 
docker push "$acrName.azurecr.io/web-api-query:latest"


# Build and push the Web App image
docker build -t "$acrName.azurecr.io/web-app:latest" -f .\src\Front\LogCorner.EduSync.Speech.Presentation\Dockerfile .\src\ 
docker push "$acrName.azurecr.io/web-app:latest"


# signalrhub
kubectl apply -f namespace.yaml
kubectl apply -f signalrhub.yaml
kubectl apply -f curl-test.yaml

kubectl exec -it curl-test -n azure-resources --   curl -v -k http://signalr-service/logcornerhub  

# webapi
kubectl apply -f workload-identity-service-account.yaml
kubectl apply -f webapi.yaml

kubectl get pods -n azure-resources
kubectl  rollout restart deployment -n azure-resources


kubectl get pods -n azure-resources
kubectl get svc -n azure-resources


kubectl logs web-frontend-app-84bb97d577-mj9gp -n azure-resources

kubectl exec -it curl-test -n azure-resources -- `
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

kubectl get pods -n azure-resources

# web api query

kubectl apply -f webapi-query.yaml

kubectl get pods -n azure-resources


kubectl logs web-api-64d6f78cc5-ps27k -n azure-resources


kubectl exec -it curl-test -n azure-resources --   curl -v -k -X GET http://web-api-query-service/api/speech 

# web app front

kubectl apply -f webapp.yaml

kubectl get pods -n azure-resources


kubectl logs web-api-64d6f78cc5-ps27k -n azure-resources


kubectl exec -it curl-test -n azure-resources --   curl -v -k -X GET http://web-api-query-service/api/speech 

kubectl  rollout restart deployment -n azure-resources