# Azure Infrastructure Architecture

## Overview

This document describes the high-level Azure infrastructure for the **LogCorner EduSync Speech** platform, deployed via Bicep IaC in the resource group `RG-EVENT-DRIVEN-ARCHITECTURE`.

The architecture follows an **Event-Driven Microservices** pattern, hosted on AKS inside a secured spoke VNet, and connected to a hub VNet via bidirectional peering.

---

## Architecture Diagram

See [`architecture.drawio`](./architecture.drawio) for the visual diagram (open with [draw.io](https://app.diagrams.net) or the VS Code draw.io extension).

---

## Components

### Networking

| Component | Description |
|---|---|
| **Spoke VNet** `10.200.0.0/16` | Main virtual network hosting all workloads |
| **Hub VNet** `RG-DATASYNCHRO-HUB` | Shared hub network, connected via bidirectional VNet peering |
| **Private DNS Zones** | 8 private DNS zones linked to both VNets to resolve private endpoints |

All inter-service communication stays on the private network. Every PaaS service is exposed through a **Private Endpoint** — no public network access is allowed.

---

### Compute

| Component | Description |
|---|---|
| **AKS Cluster** | Kubernetes cluster running all microservices. Enabled with Workload Identity and OIDC issuer for passwordless authentication to Azure services. Node pool size: `Standard_DS2_v2`. |
| **Azure Container Registry (ACR)** | Stores Docker images for all services. Integrated with AKS for seamless image pulls. Exposed via private endpoint. |
| **Deployment Script** (Container Instance) | One-time script run at deployment time to initialize the SQL database schema. Runs inside the Container Instance subnet. |

---

### Ingress

| Component | Description |
|---|---|
| **Application Gateway for Containers** | Layer 7 ingress controller for AKS workloads. Configured with a WAF policy and security policy. Uses a dedicated subnet `10.200.6.0/24`. |

---

### Identity & Security

| Component | Description |
|---|---|
| **User Assigned Managed Identity** | Used by the AKS cluster to access ACR and other Azure resources. |
| **Workload Managed Identity** | Used by application workloads running inside AKS to access Service Bus, Cosmos DB, and Azure OpenAI — without any secrets or passwords. |
| **ALB Managed Identity** | Used by the ALB controller inside AKS to manage the Application Gateway for Containers. |
| **Federated Identity Credential** | Binds the ALB Managed Identity to the AKS OIDC issuer, enabling the Kubernetes service account to acquire Azure tokens automatically. |
| **Key Vault** | Stores application secrets. Accessed by AKS workloads through the Workload Identity. Exposed via private endpoint. |

---

### Data Layer

| Component | Description |
|---|---|
| **Azure SQL Server + Database** | Relational database for the Command side (write model) of the CQRS pattern. Exposed via private endpoint. |
| **Cosmos DB (NoSQL)** | Document database for the Query side (read model) of the CQRS pattern. Exposed via private endpoint. |
| **Storage Account (Azure Files)** | File share used by the Deployment Script container to execute SQL initialization scripts. Exposed via private endpoint. |

---

### Messaging

| Component | Description |
|---|---|
| **Service Bus Namespace + Queue** | Async message broker enabling event-driven communication between the Command API (producer) and the Broker/Worker service (consumer). Exposed via private endpoint. |

---

### AI

| Component | Description |
|---|---|
| **Azure OpenAI (AI Foundry)** | Provides AI/LLM capabilities to the chatbot service running inside AKS. Accessed via the Workload Managed Identity. Exposed via private endpoint. |

---

### Observability

| Component | Description |
|---|---|
| **Log Analytics Workspace** | Central log sink for AKS, ACR, and all Azure services. |
| **Application Insights** | Application-level metrics, distributed tracing, and performance monitoring. |
| **Action Group** | Email alert notifications triggered by Azure Monitor alert rules. |
| **Azure Managed Prometheus** | Scrapes Kubernetes and workload metrics from the AKS cluster. |
| **Azure Managed Grafana** | Visualises Prometheus metrics in pre-built and custom dashboards. |

---

## Data Flow

See [`dataflow.drawio`](./dataflow.drawio) for the visual data flow diagram.

```
Internet
   │
   ▼
App Gateway for Containers   (WAF + TLS termination)
   │
   ▼
AKS Cluster
   ├── Command API  ──────► Azure SQL       (write)
   │         │
   │         └──────────► Service Bus      (publish event)
   │                           │
   │                           ▼
   │                      Worker / Broker
   │                           │
   │                           ▼
   │                       Cosmos DB        (project read model)
   │
   ├── Query API   ──────► Cosmos DB        (read)
   │
   ├── Chatbot     ──────► Azure OpenAI     (AI inference)
   │
   └── SignalR Hub          (real-time push to front-end)
```

---

## Security Principles

- **No public endpoints** — all PaaS services are accessed exclusively via Private Endpoints.
- **Passwordless authentication** — Workload Identity + Managed Identity replaces all connection strings and secrets.
- **Network isolation** — spoke VNet with dedicated subnets per workload type; peered to hub for shared services.
- **WAF protection** — Application Gateway for Containers enforces a WAF policy on all inbound traffic.
- **Secret management** — Key Vault is the single source of truth for any remaining secrets.

---

## Deployment

```powershell
$resourceGroupName = "RG-EVENT-DRIVEN-ARCHITECTURE"

New-AzResourceGroupDeployment `
  -Name "DATASYNCHRO-EVENT-DRIVEN" `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile main.bicep `
  -TemplateParameterFile main.bicepparam `
  -DeploymentDebugLogLevel All
```
