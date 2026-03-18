# LogCorner.EduSync
Building microservices through Event Driven Architecture

# deploy bicep

$resourceGroupName="RG-EVENT-DRIVEN-ARCHITECTURE"

New-AzResourceGroupDeployment `
  -Name "datasynchro-event-driven-architecture" `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile iac/bicep/main.bicep `
  -TemplateParameterFile iac/bicep/main.bicepparam `
  -DeploymentDebugLogLevel All

# Build and deploy apps

.\build_and_deploy_images.ps1 -acrName "datasynchroacr"

# deploy self signed certificate to keyvault
$pfxPassword = Read-Host "Enter PFX password" -AsSecureString
.\create_and_upload_certificate.ps1 `
  -vaultName "kv-datasynchro-004" `
  -certificateName "logcorner-datasync-cert" `
  -domain "cloud-devops-craft.com" `
  -pfxPassword $pfxPassword


# deploy helm chart
Set-Location "c:\Users\logcorner\source\repos\LogCorner.EduSync.Speech\helm-chart\chart"; 

.\deploy_helm_chart.ps1 `
  -RESOURCE_GROUP "RG-EVENT-DRIVEN-ARCHITECTURE" `
  -WORKLOAD_NAMESPACE "azure-workloads" `
  -RELEASE_NAME "logcorner-command" `
  -ALB_IDENTITY_NAME "azure_alb_identity" `
  -GATEWAY_CONTROLLER_NAMESPACE "azure-alb-system" `
  -APPLICATION_FOR_CONTAINER_HOST_NAME "app.cloud-devops-craft.com" `
  -UAMI "workload-managed-identity" `
  -CLUSTER_NAME "datasynchro-aks" `
  -CERTIFICATE_NAME "logcorner-datasync-cert" `
  -APP_GATEWAY_FOR_CONTAINER_NAME "appgwforcon-datasynchro" `
  -WAF_POLICY_NAME "appgwc-waf-policy" `
  -APP_INSIGHTS_NAME "datasyncappi"







# install helm 
https://helm.sh/docs/intro/install/

helm version --short
kubectl config view

helm repo add "stable" "https://charts.helm.sh/stable"

helm env

# go under folder => C:\Users\logcorner\source\repos\LogCorner.EduSync.Speech.Command\helm-chart\chart> 

helm install [release] [chart]
helm install  logcorner-command  logcorner.edusync.speech


helm list --short  => list release name

helm get manifest logcorner-command


helm upgrade logcorner-command  logcorner.edusync.speech

helm rollback logcorner-command 1

helm history logcorner-command 

helm uninstall logcorner-command  logcorner.edusync.speech


# cosmos db role
# principal id of azure vm (datasynchro-jumbobox) =>  1874d709-8343-4c7a-926d-d4dbb1f66ffe

az cosmosdb sql role assignment create --account-name "cosmos-datasynchro-002" --resource-group "RG-EVENT-DRIVEN-ARCHITECTURE" --scope "/" --principal-id "1874d709-8343-4c7a-926d-d4dbb1f66ffe" --role-definition-name "Cosmos DB Built-in Data Contributor" 



az cosmosdb sql role assignment list   --account-name cosmos-datasynchro-002   --resource-group RG-EVENT-DRIVEN-ARCHITECTURE   --query "[].{principalId:principalId, roleDefinitionId:roleDefinitionId, scope:scope}"









install ingress for doecker desktop
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/aws/deploy.yaml

kubectl get pods -n ingress-nginx --watch

C:\Windows\System32\drivers\etc\hosts

127.0.0.1 kubernetes.docker.com

curl http://kubernetes.docker.com
https://kubernetes.docker.com/speech-command-http-api/swagger/index.html


eneable ssl
https://slproweb.com/products/Win32OpenSSL.html


openssl req -x509 -nodes -days 365 -newkey rsa:2048 -out logcorner-ingress-tls.crt -keyout logcorner-ingress-tls.key -subj "/CN=kubernetes.docker.com/O=logcorner-ingress-tls"

kubectl create namespace qa
kubectl create secret tls logcorner-ingress-tls --namespace qa --key logcorner-ingress-tls.key --cert logcorner-ingress-tls.crt

https://kubernetes.docker.com/speech-command-http-api/swagger/index.html

# create
{
  "title": "this is a title",
  "description": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
  "url": "http://test.com",
  "typeId": 1
}

# update

{
  "id": "97d37b4b-0823-418d-919c-1244eda7d91b",
  "title": "mod this is a title",
  "description": "mod_ Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
  "url": "http://update.com",
  "typeId": 2,
  "version": 0
}

# delete
{
  "id": "97d37b4b-0823-418d-919c-1244eda7d91b",
  "version": 4
}

https://github.com/serilog/serilog-sinks-opentelemetry