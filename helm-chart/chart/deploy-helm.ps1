
$RESOURCE_GROUP = "RG-EVENT-DRIVEN-ARCHITECTURE"
$WORKLOAD_NAMESPACE = "azure-workloads"
$RELEASE_NAME = "logcorner-command"

$ALB_IDENTITY_NAME = "azure_alb_identity"

$GatewayControllerNamespace = "azure-alb-system"

# $ALB_RESOURCES_NAMESPACE = "azure-alb-resources"
$APPLICATION_FOR_CONTAINER_HOST_NAME = "app.cloud-devops-craft.com"


$UAMI="workload-managed-identity"
$CLUSTER_NAME="datasynchro-aks"

$CERTIFICATE_NAME="logcorner-datasync-cert"
$APP_GATEWAY_FOR_CONTAINER_NAME="appgwforcon-datasynchro"

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

$USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group $RESOURCE_GROUP --name $UAMI --query 'clientId' -o tsv)"
write-host "USER_ASSIGNED_CLIENT_ID: $USER_ASSIGNED_CLIENT_ID"

$KEYVAULT_TENANT = (az account show --query tenantId -o tsv)
Write-Host "KEYVAULT_TENANT: $KEYVAULT_TENANT"


$AKS_OIDC_ISSUER="$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)"
write-host "AKS_OIDC_ISSUER: $AKS_OIDC_ISSUER"


$ApplicationForContainerResource = Get-AzResource -ResourceGroupName $RESOURCE_GROUP -ResourceType "Microsoft.ServiceNetworking/trafficControllers" -Name $APP_GATEWAY_FOR_CONTAINER_NAME
$ApplicationForContainerResourceId = $ApplicationForContainerResource.ResourceId

write-host "ApplicationForContainerResourceId: $ApplicationForContainerResourceId"

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

choco install kubernetes-cli azure-kubelogin

helm repo add "stable" "https://charts.helm.sh/stable"

kubelogin convert-kubeconfig -l azurecli


# Deploy or upgrade the ALB controller using Helm
# The controller uses workload identity (managed identity client ID) for Azure authentication
# Skip schema validation to avoid potential Helm chart validation issues
helm upgrade --install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller `
  --create-namespace `
  --namespace $GatewayControllerNamespace `
  --version 1.9.11 `
  --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n $ALB_IDENTITY_NAME --query clientId -o tsv) `
  --skip-schema-validation

$ALB_CONTROLLER_CLIENT_ID = kubectl get deploy alb-controller -n $GatewayControllerNamespace -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="AZURE_CLIENT_ID")].value}'
if ([string]::IsNullOrWhiteSpace($ALB_CONTROLLER_CLIENT_ID)) {
  throw "ALB controller AZURE_CLIENT_ID is empty. Verify ALB_IDENTITY_NAME and RESOURCE_GROUP, then rerun Helm install."
}
Write-Host "ALB_CONTROLLER_CLIENT_ID: $ALB_CONTROLLER_CLIENT_ID"


# Display all pods in the controller namespace with their labels
kubectl get pod  -n  $GatewayControllerNamespace  --show-labels

# Wait for the ALB controller pod to be ready (timeout: 3 minutes)
kubectl wait pod  -n $GatewayControllerNamespace  -l app=alb-controller --for=condition=Ready  --timeout=180s

# kubectl describe pod busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE



helm upgrade --install  $RELEASE_NAME  logcorner.edusync.speech --set azureWorkloadIdentityClientId=$USER_ASSIGNED_CLIENT_ID `
                                                                --set applicationGatewayForContainerResourceId=$ApplicationForContainerResourceId `
                                                                --set tenantId=$KEYVAULT_TENANT 

kubectl get pods -n $WORKLOAD_NAMESPACE

kubectl exec busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE -- ls /mnt/secrets-store/ 

kubectl exec busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE -- cat /mnt/secrets-store/$CERTIFICATE_NAME
kubectl exec busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE -- cat /mnt/secrets-store/$CERTIFICATE_NAME.crt
kubectl exec busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE -- cat /mnt/secrets-store/$CERTIFICATE_NAME.key


kubectl get gateway gateway-01 -n $WORKLOAD_NAMESPACE -o yaml


kubectl get httproute http-route -n $WORKLOAD_NAMESPACE -o yaml

kubectl get svc -n $WORKLOAD_NAMESPACE

kubectl get sa -n $WORKLOAD_NAMESPACE

kubectl rollout restart deployment -n $WORKLOAD_NAMESPACE
kubectl rollout restart deployment -n $WORKLOAD_NAMESPACE

kubectl get pods -n $WORKLOAD_NAMESPACE

# helm uninstall $RELEASE_NAME  logcorner.edusync.speech


kubectl get pods -n $WORKLOAD_NAMESPACE
$fqdn=$(kubectl get gateway "gateway-01" -n $WORKLOAD_NAMESPACE -o jsonpath='{.status.addresses[0].value}')

Write-Host "fqdn=$fqdn"

$fqdnIp = (Resolve-DnsName $fqdn | Where-Object { $_.Type -eq "A" }).IPAddress

Write-Host "fqdnIp=$fqdnIp"


curl -k --resolve "${APPLICATION_FOR_CONTAINER_HOST_NAME}:443:${fqdnIp}" "https://$APPLICATION_FOR_CONTAINER_HOST_NAME/webapp/" --insecure

