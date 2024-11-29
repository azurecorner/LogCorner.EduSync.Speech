param(
    [string]$ChartName = "logcorner.edusync.speech",
    [string]$IMAGE_TAG = "1130",
    [string]$NAMESPACE = "ingress-nginx",
    [string]$RESOURCE_GROUP_NAME = "rg-edusync-dev",
    [string]$CLUSTER_NAME = "aks-edusync-dev",
    [string]$PrivateDnsZoneName = "cloud-devops-craft.com",
    [string]$RecordName = "ingress"
   )
# $VNET_NAME="edusync-vnet"
# $RESOURCE_GROUP_NAME="rg-edusync-dev"
# $NAMESPACE="ingress-nginx"
# $CLUSTER_NAME="aks-edusync-dev"
# $IMAGE_TAG="1117"
#First, we need a private IP address that the NGINX ingress controller will accept requests from. So, choose a private IP address and verify that it’s available. In this case, the IP address I choose is
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --overwrite-existing
kubectl get deployments --all-namespaces=true
# az network vnet check-ip-address --name $VNET_NAME -g $RESOURCE_GROUP_NAME --ip-address $PRIVATE_IP

# Add the ingress-nginx Helm repository if not already added
Write-Host "Adding the ingress-nginx repository..." -ForegroundColor Green
 # Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Update the Helm repo to ensure we have the latest charts
helm repo update

# Deploy the NGINX ingress controller with an internal load balancer
Write-Host "Deploying the NGINX ingress controller..." -ForegroundColor Green
# # Use Helm to deploy an NGINX ingress controllerusing static private IP address
#  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx  `
#   --namespace $NAMESPACE  `
#   --create-namespace  `
#   --set controller.service.type=LoadBalancer  `
#   --set controller.service.loadBalancerIP=$PRIVATE_IP  `
#   --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"="true" 

# Use Helm to deploy an NGINX ingress controller without static private IP address
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx  `
--namespace $NAMESPACE  `
--create-namespace  `
--set controller.service.type=LoadBalancer  `
--set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"="true" 
    
# Test an internal IP address
# Monitor the ingress service
Write-Host "Monitoring ingress-nginx-controller service..." -ForegroundColor Green
#kubectl  get services -o wide -w ingress-nginx-controller -n $NAMESPACE

######kubectl get service ingress-nginx-controller --namespace  $NAMESPACE


##########

#$NAMESPACE = "your-namespace"  # Replace with your namespace
$ServiceName = "ingress-nginx-controller"

Write-Host "Waiting for external IP for service '$ServiceName' in namespace '$NAMESPACE'..."

do {
    $externalIP = kubectl get service $ServiceName --namespace $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    if (-not $externalIP) {
        Write-Host "External IP is still pending. Retrying in 5 seconds..."
        Start-Sleep -Seconds 5
    }
} while (-not $externalIP)

Write-Host "Service is ready! External IP: $externalIP"


##########

# Deploy an additional Helm chart (logcorner-command)
Write-Host "Deploying logcorner-command chart..." -ForegroundColor Green
# Change to the correct directory (up one level)
# Define the full path to the Helm chart directory
#$ChartName = "logcorner.edusync.speech"


# kubectl delete pod curl-test --namespace  helm

$status = kubectl get pod curl-test --namespace helm -o jsonpath='{.status.phase}'
if ($status -ne "Running") {
    kubectl delete pod curl-test --namespace helm
}


# helm upgrade --install logcorner-command  $ChartName
helm upgrade --install logcorner-command $ChartName `
    --set global.tag=$IMAGE_TAG

$NAMESPACE="default"
write-host "Waiting for the logcorner-command pod to be ready... " -ForegroundColor Green
kubectl wait --for=condition=ready pod -l app=logcorner-command-http-api --timeout=300s

kubectl get pods --namespace  $NAMESPACE

$NAMESPACE="ingress-nginx"
kubectl get service ingress-nginx-controller --namespace  $NAMESPACE

Write-Host "Getting private ip of ingress controller..." -ForegroundColor Green

$PRIVATE_IP=kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

Write-Host "Adding dns record to private dns zone..." -ForegroundColor Green

# az network private-dns record-set a add-record  `
#   -g $RESOURCE_GROUP_NAME  `
#   -z cloud-devops-craft.com  `
#   -n ingress  `
#   -a $PRIVATE_IP

# $RecordName = "ingress"
# $PrivateDnsZoneName = "cloud-devops-craft.com"
# Check if the record exists
$existingRecord = az network private-dns record-set a show `
  -g $RESOURCE_GROUP_NAME `
  -z $PrivateDnsZoneName  `
  -n $RecordName  `
  --query "aRecords[?ipv4Address=='$PRIVATE_IP']" `
  --output tsv

if (-not $existingRecord) {
    Write-Host "Record does not exist. Adding A record..." -ForegroundColor Green
    az network private-dns record-set a add-record `
      -g $RESOURCE_GROUP_NAME `
      -z $PrivateDnsZoneName  `
      -n $RecordName `
      -a $PRIVATE_IP
    Write-Host "A record added: $RecordName -> $PRIVATE_IP" -ForegroundColor Green
} else {
    Write-Host "Record already exists: $RecordName -> $PRIVATE_IP" -ForegroundColor Yellow
}

Write-Host "Running dns resolution between $PrivateDnsZoneName and $PRIVATE_IP  ..." -ForegroundColor Green
kubectl exec -it curl-test -n helm -- nslookup ingress.cloud-devops-craft.com

Write-Host "Running test ..." -ForegroundColor Green

Write-Host "Getting all WeatherForecast ..." -ForegroundColor Green

kubectl exec -it curl-test -n helm -- curl http://ingress.cloud-devops-craft.com/aks-command-api/WeatherForecast

Write-Host "`nGetting  WeatherForecast by id ..." -ForegroundColor Green

kubectl exec -it curl-test -n helm -- curl http://ingress.cloud-devops-craft.com/aks-command-api/WeatherForecast/1

# kubectl exec -it curl-test -n helm -- curl http://$PRIVATE_IP/aks-command-api/WeatherForecast


<# $ChartName = "logcorner.edusync.speech"
kubectl exec -it curl-test -n helm -- curl http://10.10.1.7/aks-command-api/WeatherForecast
# Use --reuse-values to keep any existing values (if needed)
helm upgrade --install logcorner-command $ChartName `
    --set global.tag=$IMAGE_TAG
 #>


#  kubectl exec -it curl-test -n helm -- curl -X 'POST' \
#  'http://10.10.1.7/aks-command-api/api/speech' \
#  -H 'accept: */*' \
#  -H 'Content-Type: application/json' \
#  -d '{
#  "title": "3_Lorem Ipsum is simply dummy text",
#  "description": "3_Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry'\''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. ",
#  "url": "http://3_test.com",
#  "type": 3
# }'