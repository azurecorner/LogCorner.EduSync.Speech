
#!/bin/bash

# Exit the script immediately if a command exits with a non-zero status
set -e

# Display each command before executing it (optional for debugging)
set -x


#First, we need a private IP address that the NGINX ingress controller will accept requests from. So, choose a private IP address and verify that it’s available. In this case, the IP address I choose is
az aks get-credentials --resource-group rg-edusync-dev --name aks-edusync-dev --overwrite-existing
kubectl get deployments --all-namespaces=true
az network vnet check-ip-address --name $VNET_NAME -g "rg-iasp-eun-lz-network" --ip-address 10.231.58.4 # $PRIVATE_IP

 # Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Use Helm to deploy an NGINX ingress controller
 helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.loadBalancerIP=10.10.1.7 \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"="true" 
    
# Test an internal IP address

kubectl --namespace iass-eun-drillx-ingress get services -o wide -w ingress-nginx-controller

helm upgrade --install logcorner-command  logcorner.edusync.speech


