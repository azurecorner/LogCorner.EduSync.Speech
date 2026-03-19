# LogCorner.EduSync
Building microservices through Event Driven Architecture
# LogCorner.EduSync.Speech

> Building microservices through Event Driven Architecture on Azure Kubernetes Service (AKS)

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [1. Deploy Infrastructure (Bicep)](#1-deploy-infrastructure-bicep)
- [2. Build and Deploy Container Images](#2-build-and-deploy-container-images)
- [3. Upload TLS Certificate to Key Vault](#3-upload-tls-certificate-to-key-vault)
- [4. Deploy with Helm](#4-deploy-with-helm)
- [Local Development](#local-development)
- [Kubernetes Operations](#kubernetes-operations)
- [Helm Reference](#helm-reference)
- [CI/CD](#cicd)

---

## Overview

**LogCorner.EduSync.Speech** is a cloud-native, event-driven microservices solution built on .NET and deployed to Azure. It follows CQRS and Event Sourcing patterns and is composed of the following services:

| Service | Description |
|---|---|
| **Command API** | Handles write operations (CQRS command side) |
| **Query API** | Handles read operations backed by Cosmos DB |
| **Broker / Worker** | Consumes domain events via Azure Service Bus and projects read models |
| **SignalR Hub** | Pushes real-time updates to connected clients |
| **Chatbot** | AI-assisted chatbot service |

---

## Architecture

The solution is hosted on **Azure Kubernetes Service (AKS)** and uses the following Azure services:

- **Azure Container Registry (ACR)** — stores Docker images
- **Azure Service Bus** — event bus between Command and Broker services
- **Azure Cosmos DB** — read-model store for the Query side
- **Azure Key Vault** — secrets and TLS certificate storage
- **Application Gateway for Containers** — ingress with WAF policy
- **Azure Monitor / Application Insights** — observability and telemetry
- **Azure Managed Identity / Workload Identity** — passwordless authentication for pods

See [iac/bicep/architecture.md](iac/bicep/architecture.md) for the architecture diagram.

---

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) with the `alb` extension
- [Azure PowerShell (`Az` module)](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) — verify with `helm version --short`
- [Docker](https://docs.docker.com/get-docker/)
- An Azure subscription with the following resource providers registered:

```powershell
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.NetworkFunction
az provider register --namespace Microsoft.ServiceNetworking
az extension add --name alb
```

---

## 1. Deploy Infrastructure (Bicep)

All Azure resources are defined as code under `iac/bicep/`. Deploy them with:

```powershell
$resourceGroupName = "RG-EVENT-DRIVEN-ARCHITECTURE"

New-AzResourceGroupDeployment `
  -Name "datasynchro-event-driven-architecture" `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile iac/bicep/main.bicep `
  -TemplateParameterFile iac/bicep/main.bicepparam `
  -DeploymentDebugLogLevel All
```

> Parameters such as ACR name, Key Vault name, AKS cluster name, and domain are defined in `iac/bicep/main.bicepparam`.

---

## 2. Build and Deploy Container Images

Build all service images and push them to Azure Container Registry:

```powershell
.\build_and_deploy_images.ps1 -acrName "datasynchroacr"
```

---

## 3. Upload TLS Certificate to Key Vault

Generate a self-signed certificate and upload it to Key Vault for use by the Application Gateway:

```powershell
$pfxPassword = Read-Host "Enter PFX password" -AsSecureString

.\create_and_upload_certificate.ps1 `
  -vaultName        "kv-datasynchro-005" `
  -certificateName  "logcorner-datasync-cert" `
  -domain           "cloud-devops-craft.com" `
  -pfxPassword      $pfxPassword
```

---

## 4. Deploy with Helm

The Helm chart is located at `helm-chart/chart/`. A convenience script handles all required parameters:

```powershell
Set-Location "helm-chart\chart"

.\deploy_helm_chart.ps1 `
  -RESOURCE_GROUP                      "RG-EVENT-DRIVEN-ARCHITECTURE" `
  -WORKLOAD_NAMESPACE                  "azure-workloads" `
  -RELEASE_NAME                        "logcorner-command" `
  -ALB_IDENTITY_NAME                   "azure_alb_identity" `
  -GATEWAY_CONTROLLER_NAMESPACE        "azure-alb-system" `
  -APPLICATION_FOR_CONTAINER_HOST_NAME "app.cloud-devops-craft.com" `
  -UAMI                                "workload-managed-identity" `
  -CLUSTER_NAME                        "datasynchro-aks" `
  -CERTIFICATE_NAME                    "logcorner-datasync-cert" `
  -APP_GATEWAY_FOR_CONTAINER_NAME      "appgwforcon-datasynchro" `
  -WAF_POLICY_NAME                     "appgwc-waf-policy" `
  -APP_INSIGHTS_NAME                   "datasyncappi"
```

---


# List pods and services
kubectl get pods -n azure-workloads
kubectl get svc  -n azure-workloads

# Restart all deployments
kubectl rollout restart deployment -n azure-workloads

# View pod logs
kubectl logs <pod-name> -n azure-workloads

# Test SignalR Hub from within the cluster
kubectl exec -it curl-test -n azure-workloads -- curl -v -k http://signalr-service/logcornerhub

# Test Command API from within the cluster
kubectl exec -it curl-test -n azure-workloads -- `
  curl -v -k -X POST http://webapi-service/api/speech `
  -H "Content-Type: application/json" `
  -d '{"title":"this is a title","description":"Lorem Ipsum ...","url":"http://test.com","typeId":1}'
```

---

## Helm Reference

```powershell
# Add the stable repo
helm repo add stable https://charts.helm.sh/stable

# Install a release
helm install logcorner-command logcorner.edusync.speech

# List releases
helm list --short

# Inspect rendered manifests
helm get manifest logcorner-command

# Upgrade a release
helm upgrade logcorner-command logcorner.edusync.speech

# Roll back to a previous revision
helm rollback logcorner-command 1

# View release history
helm history logcorner-command

# Uninstall a release
helm uninstall logcorner-command
```

---

## CI/CD

Azure Pipelines definitions are located in:

| File | Purpose |
|---|---|
| `cicd/dotnet/azure-pipelines.yml` | Build and test .NET services |
| `cicd/azure-pipelines-db.yml` | Database migrations |
| `cicd/azure-pipelines-helm.yml` | Helm chart deployment |
| `src/broker/azure-pipelines.yml` | Broker service pipeline |

---

## References

- [Azure AKS Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster)
- [Application Gateway for Containers (Bicep samples)](https://learn.microsoft.com/en-us/samples/azure-samples/aks-application-gateway-for-containers-bicep/aks-application-gateway-for-containers-bicep/)
- [Using Managed Identities with Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/how-to-connect-role-based-access-control)
- [Helm Docs](https://helm.sh/docs/)


