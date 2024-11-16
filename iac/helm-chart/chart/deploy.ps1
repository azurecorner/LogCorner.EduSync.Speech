$VNET_NAME="edusync-vnet"
$RESOURCE_GROUP_NAME="rg-edusync-dev"
$PRIVATE_IP="10.10.1.4"
$NAMESPACE="ingress-nginx"
$CLUSTER_NAME="aks-edusync-dev"
#First, we need a private IP address that the NGINX ingress controller will accept requests from. So, choose a private IP address and verify that it’s available. In this case, the IP address I choose is
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME --overwrite-existing
kubectl get deployments --all-namespaces=true
az network vnet check-ip-address --name $VNET_NAME -g $RESOURCE_GROUP_NAME --ip-address $PRIVATE_IP

# Add the ingress-nginx Helm repository if not already added
Write-Output "Adding the ingress-nginx repository..."
 # Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Update the Helm repo to ensure we have the latest charts
helm repo update

# Deploy the NGINX ingress controller with an internal load balancer
Write-Output "Deploying the NGINX ingress controller..."
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
Write-Output "Monitoring ingress-nginx-controller service..."
#kubectl  get services -o wide -w ingress-nginx-controller -n $NAMESPACE
kubectl get service ingress-nginx-controller --namespace  $NAMESPACE

# Deploy an additional Helm chart (logcorner-command)
Write-Output "Deploying logcorner-command chart..."
# Change to the correct directory (up one level)
# Define the full path to the Helm chart directory
$ChartName = "logcorner.edusync.speech"

helm upgrade --install logcorner-command  $ChartName
$NAMESPACE="default"
write-host "Waiting for the logcorner-command pod to be ready..."
kubectl get pods --namespace  $NAMESPACE

$NAMESPACE="ingress-nginx"
kubectl get service ingress-nginx-controller --namespace  $NAMESPACE


$PRIVATE_IP=kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'


# az network private-dns record-set a add-record  `
#   -g $RESOURCE_GROUP_NAME  `
#   -z cloud-devops-craft.com  `
#   -n ingress  `
#   -a $PRIVATE_IP

$RecordName = "ingress"
$PrivateDnsZoneName = "cloud-devops-craft.com"
# Check if the record exists
$existingRecord = az network private-dns record-set a show `
  -g $RESOURCE_GROUP_NAME `
  -z $PrivateDnsZoneName  `
  -n $RecordName  `
  --query "aRecords[?ipv4Address=='$PRIVATE_IP']" `
  --output tsv

if (-not $existingRecord) {
    Write-Host "Record does not exist. Adding A record..."
    az network private-dns record-set a add-record `
      -g $RESOURCE_GROUP_NAME `
      -z $PrivateDnsZoneName  `
      -n $RecordName `
      -a $PRIVATE_IP
    Write-Host "A record added: $RecordName -> $PRIVATE_IP"
} else {
    Write-Host "Record already exists: $RecordName -> $PRIVATE_IP"
}

kubectl exec -it curl-test -n helm -- nslookup ingress.cloud-devops-craft.com

kubectl exec -it curl-test -n helm -- curl http://ingress.cloud-devops-craft.com/aks-command-api/WeatherForecast


# kubectl exec -it curl-test -n helm -- curl http://$PRIVATE_IP/aks-command-api/WeatherForecast