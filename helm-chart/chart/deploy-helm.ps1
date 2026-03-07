$RESOURCE_GROUP = "RG-EVENT-DRIVEN-ARCHITECTURE"
$WORKLOAD_NAMESPACE = "azure-workloads"
$RELEASE_NAME = "logcorner-command"

$ALB_IDENTITY_NAME = "azure_alb_identity"

$GATEWAY_CONTROLLER_NAMESPACE = "azure-alb-system"

# $ALB_RESOURCES_NAMESPACE = "azure-alb-resources"
$APPLICATION_FOR_CONTAINER_HOST_NAME = "app.cloud-devops-craft.com"


$UAMI="workload-managed-identity"
$CLUSTER_NAME="datasynchro-aks"

$CERTIFICATE_NAME="logcorner-datasync-cert"
$APP_GATEWAY_FOR_CONTAINER_NAME="appgwforcon-datasynchro"

$WAF_POLICY_NAME="appgwc-waf-policy"

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

$USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group $RESOURCE_GROUP --name $UAMI --query 'clientId' -o tsv)"
write-host "USER_ASSIGNED_CLIENT_ID: $USER_ASSIGNED_CLIENT_ID"

$KEYVAULT_TENANT = (az account show --query tenantId -o tsv)
Write-Host "KEYVAULT_TENANT: $KEYVAULT_TENANT"


$AKS_OIDC_ISSUER="$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)"
write-host "AKS_OIDC_ISSUER: $AKS_OIDC_ISSUER"


# Retrieve the Application Gateway for Containers resource to get its Resource ID for use in the Helm chart deployment. This is necessary because the ALB controller needs to associate the Application Gateway for Containers with the deployed workloads.

$ApplicationForContainerResource = Get-AzResource -ResourceGroupName $RESOURCE_GROUP -ResourceType "Microsoft.ServiceNetworking/trafficControllers" -Name $APP_GATEWAY_FOR_CONTAINER_NAME
$ApplicationForContainerResourceId = $ApplicationForContainerResource.ResourceId

write-host "ApplicationForContainerResourceId: $ApplicationForContainerResourceId"


# Retrieve the Web Application Firewall Policy resource to get its Resource ID for use in the Helm chart deployment. This is necessary because the ALB controller needs to associate the

$webApplicationFirewall = Get-AzResource -ResourceGroupName $RESOURCE_GROUP -ResourceType "Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies" -Name $WAF_POLICY_NAME -ErrorAction SilentlyContinue

if ($null -eq $webApplicationFirewall) {
    throw "Web Application Firewall Policy '$WAF_POLICY_NAME' not found in resource group '$RESOURCE_GROUP'"
}

Write-Host "Web Application Firewall Policy found: $($webApplicationFirewall.Name) with ID: $($webApplicationFirewall.ResourceId)"
$webApplicationFirewallResourceId = $webApplicationFirewall.ResourceId

write-host "webApplicationFirewallResourceId: $webApplicationFirewallResourceId"

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

choco install kubernetes-cli azure-kubelogin

helm repo add "stable" "https://charts.helm.sh/stable"

kubelogin convert-kubeconfig -l azurecli


# Deploy or upgrade the ALB controller using Helm
# The controller uses workload identity (managed identity client ID) for Azure authentication
# Skip schema validation to avoid potential Helm chart validation issues
helm upgrade --install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller `
  --create-namespace `
  --namespace $GATEWAY_CONTROLLER_NAMESPACE `
  --version 1.9.11 `
  --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n $ALB_IDENTITY_NAME --query clientId -o tsv) `
  --skip-schema-validation

$ALB_CONTROLLER_CLIENT_ID = kubectl get deploy alb-controller -n $GATEWAY_CONTROLLER_NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="AZURE_CLIENT_ID")].value}'
if ([string]::IsNullOrWhiteSpace($ALB_CONTROLLER_CLIENT_ID)) {
  throw "ALB controller AZURE_CLIENT_ID is empty. Verify ALB_IDENTITY_NAME and RESOURCE_GROUP, then rerun Helm install."
}
Write-Host "ALB_CONTROLLER_CLIENT_ID: $ALB_CONTROLLER_CLIENT_ID"


# Display all pods in the controller namespace with their labels
kubectl get pod  -n  $GATEWAY_CONTROLLER_NAMESPACE  --show-labels

# Wait for the ALB controller pod to be ready (timeout: 3 minutes)
kubectl wait pod  -n $GATEWAY_CONTROLLER_NAMESPACE  -l app=alb-controller --for=condition=Ready  --timeout=180s

# kubectl describe pod busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE



helm upgrade --install  $RELEASE_NAME  logcorner.edusync.speech --set azureWorkloadIdentityClientId=$USER_ASSIGNED_CLIENT_ID `
                                                                --set applicationGatewayForContainerResourceId=$ApplicationForContainerResourceId `
                                                                --set webApplicationFirewallResourceId=$webApplicationFirewallResourceId `
                                                                --set tenantId=$KEYVAULT_TENANT 

#kubectl rollout restart deployment -n $WORKLOAD_NAMESPACE
kubectl get pods -n $WORKLOAD_NAMESPACE

kubectl exec busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE -- ls /mnt/secrets-store/ 

kubectl exec busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE -- cat /mnt/secrets-store/$CERTIFICATE_NAME
kubectl exec busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE -- cat /mnt/secrets-store/$CERTIFICATE_NAME.crt
kubectl exec busybox-secrets-store-inline-wi -n $WORKLOAD_NAMESPACE -- cat /mnt/secrets-store/$CERTIFICATE_NAME.key


kubectl get gateway gateway-01 -n $WORKLOAD_NAMESPACE -o yaml


kubectl get httproute http-route -n $WORKLOAD_NAMESPACE -o yaml

kubectl get webapplicationfirewallpolicy -n $WORKLOAD_NAMESPACE $WAF_POLICY_NAME -o yaml

kubectl get svc -n $WORKLOAD_NAMESPACE

kubectl get sa -n $WORKLOAD_NAMESPACE


# helm uninstall $RELEASE_NAME  logcorner.edusync.speech


kubectl get pods -n $WORKLOAD_NAMESPACE
$fqdn=$(kubectl get gateway "gateway-01" -n $WORKLOAD_NAMESPACE -o jsonpath='{.status.addresses[0].value}')

Write-Host "fqdn=$fqdn"

$fqdnIp = (Resolve-DnsName $fqdn | Where-Object { $_.Type -eq "A" }).IPAddress

Write-Host "fqdnIp=$fqdnIp"


curl -k --resolve "${APPLICATION_FOR_CONTAINER_HOST_NAME}:443:${fqdnIp}" "https://$APPLICATION_FOR_CONTAINER_HOST_NAME/webapp/" --insecure

# self hosted gateway test

kubectl exec -it curl-test -n azure-workloads -- curl -v -k http://10.0.137.205/api/speech

kubectl exec -it curl-test -n azure-workloads -- curl -v -k http://web-api-query-service.azure-workloads.svc.cluster.local/api/speech