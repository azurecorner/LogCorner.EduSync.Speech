$AKS_NAME="datasynchro-aks"
$RESOURCE_GROUP="RG-EVENT-DRIVEN-ARCHITECTURE"
$HELM_NAMESPACE="azure-workloads"
$RESOURCE_NAME="appgwforcon-datasynchro"
$FRONTEND_NAME="datasynchro-frontend"
 
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing

$RESOURCE_ID=$(az network alb show --resource-group $RESOURCE_GROUP --name $RESOURCE_NAME --query id -o tsv)

Write-Output "RESOURCE_ID=$RESOURCE_ID"

$IDENTITY_RESOURCE_NAME="workload-managed-identity-datasynchro"
$miClientId=$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query clientId -o tsv)

write-Output "MI PRINCIPAL ID: $miClientId"

Write-Host "Deploying Helm Chart..." -ForegroundColor Yellow


helm upgrade --install logcorner-command ".\helm-chart\chart\logcorner.edusync.speech" `
  --set azureWorkloadIdentityClientId=$miClientId  --set applicationGatewayForContainerResourceId=$RESOURCE_ID `
  --set applicationGatewayForContainerFrontEndName=$FRONTEND_NAME # add cosmosdb connection string

kubectl get gateway gateway-01 -n $HELM_NAMESPACE -o yaml

kubectl get serviceAccount -n $HELM_NAMESPACE

kubectl get svc -n $HELM_NAMESPACE
kubectl get endpoints -n $HELM_NAMESPACE
kubectl get pods -n $HELM_NAMESPACE -o wide

Write-Host "Retrieving Application FQDN..." -ForegroundColor Yellow

$fqdn=$(kubectl get gateway gateway-01 -n $HELM_NAMESPACE -o jsonpath='{.status.addresses[0].value}')

Write-Host "fqdn=$fqdn"

write-Host "Testing Application Endpoints..." -ForegroundColor Yellow

$resp = Invoke-WebRequest "http://$fqdn/webapp/" -UseBasicParsing -ErrorAction Stop
       Write-Host "Frontend Weapp Status: $($resp.StatusCode)" -ForegroundColor Green
       Write-Host $resp.Content -ForegroundColor Green

write-Host "Testing SignalR Hub Endpoint..." -ForegroundColor Yellow

$resp = Invoke-WebRequest "http://$fqdn/signalr/logcornerhub/negotiate" -Method POST -UseBasicParsing -ErrorAction Stop
       Write-Host "Signalr Hub Status: $($resp.StatusCode)" -ForegroundColor Green
       Write-Host $resp.Content -ForegroundColor Green
