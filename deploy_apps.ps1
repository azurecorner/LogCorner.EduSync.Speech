$AKS_NAME="datasynchro-aks"
$RESOURCE_GROUP="RG-EVENT-DRIVEN-ARCHITECTURE"

$HELM_NAMESPACE="azure-resources"

$RESOURCE_NAME="appgwforcon-datasynchro"
$FRONTEND_NAME="datasynchro-frontend"

 
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing


 $RESOURCE_ID=$(az network alb show --resource-group $RESOURCE_GROUP --name $RESOURCE_NAME --query id -o tsv)

 Write-Output "RESOURCE_ID=$RESOURCE_ID"

@"
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-01
  namespace: $HELM_NAMESPACE
  annotations:
    alb.networking.azure.io/alb-id: $RESOURCE_ID
spec:
  gatewayClassName: azure-alb-external
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
  addresses:
  - type: alb.networking.azure.io/alb-frontend
    value: $FRONTEND_NAME
"@ | kubectl apply -f -


 kubectl get gateway gateway-01 -n $HELM_NAMESPACE -o yaml


 # signalrhub
kubectl apply -f .\deploy\namespace.yaml
kubectl apply -f .\deploy\signalrhub.yaml
kubectl apply -f .\deploy\curl-test.yaml

kubectl exec -it curl-test -n azure-resources --   curl -v -k http://signalr-service/logcornerhub  


# web api command
kubectl apply -f .\deploy\workload-identity-service-account.yaml
kubectl apply -f .\deploy\webapi.yaml

# web api query

kubectl apply -f .\deploy\webapi-query.yaml


# broker service
kubectl apply -f .\deploy\workload-identity-service-account.yaml
kubectl apply -f .\deploy\broker.yaml


# web app front

kubectl apply -f .\deploy\webapp.yaml


# deploy routes
 kubectl apply -f .\deploy\http-routes.yaml

 kubectl get httproute webapps-route -n $HELM_NAMESPACE -o yaml

 # verify deployment
 #kubectl  rollout restart deployment -n azure-resources

 kubectl get svc -n $HELM_NAMESPACE
 kubectl get endpoints -n $HELM_NAMESPACE
 kubectl get pods -n $HELM_NAMESPACE -o wide


 $fqdn=$(kubectl get gateway gateway-01 -n $HELM_NAMESPACE -o jsonpath='{.status.addresses[0].value}')

 Write-Host "fqdn=$fqdn"

 $resp = Invoke-WebRequest "http://$fqdn/webapp/" -UseBasicParsing -ErrorAction Stop
        Write-Host "Frontend Weapp Status: $($resp.StatusCode)" -ForegroundColor Green
        Write-Host $resp.Content -ForegroundColor Green


$resp = Invoke-WebRequest "http://$fqdn/signalr/logcornerhub/negotiate" -Method POST -UseBasicParsing -ErrorAction Stop
        Write-Host "Signalr Hub Status: $($resp.StatusCode)" -ForegroundColor Green
        Write-Host $resp.Content -ForegroundColor Green



