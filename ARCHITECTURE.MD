# LogCorner.EduSync.Speech Architecture

---

## 1) System Overview

This section describes the platform at a high level, including its core architectural style, principal runtime components, and how responsibilities are split across write, read, messaging, real-time, and AI capabilities.

LogCorner.EduSync.Speech is an event-driven microservices platform deployed on AKS, following CQRS patterns:

- **Write side**: Command API + Azure SQL
- **Event transport**: Azure Service Bus queue
- **Projection side**: Broker/Worker updates read model in Cosmos DB
- **Read side**: Query API over Cosmos DB
- **Real-time notifications**: SignalR Hub
- **User-facing app**: Front-end MVC app consuming APIs + hub
- **AI feature**: Chatbot service using Azure OpenAI

### How data flows across these components

1. The front-end sends write requests (create/update/delete) to the **Command API**.
2. The Command API persists transactional state in **Azure SQL**.
3. After successful writes, events are published to an **Azure Service Bus queue**.
4. The **Broker/Worker** consumes those events and updates read projections in **Cosmos DB**.
5. The front-end retrieves query data through the **Query API**, which reads from Cosmos DB.
6. The **SignalR Hub** pushes real-time update notifications to connected clients.
7. The **Chatbot service** handles conversational requests and calls **Azure OpenAI** for AI inference.

---

## 2) Azure Infrastructure Topology

Based on `architecture.drawio` and Bicep deployment artifacts.

### Network

- **Hub VNet** with a **Jump Box**
- **Spoke VNet** hosting AKS and supporting PaaS resources
- **Hub ↔ Spoke peering**
- **Private DNS Zones** linked to hub and spoke VNets to resolve private endpoint FQDNs
- Architecture note in diagram indicates all services are secured via **Private Endpoints** (no public network access)

### Core Platform Services

- **AKS Cluster** (Workload Identity + OIDC)
- **Application Gateway for Containers** (ingress, WAF, TLS termination)
- **Azure Container Registry (ACR)**
- **Managed Identities** (cluster, workload, and ALB identities)
- **Deployment Script (Container Instance)** for one-time SQL schema/database initialization

### Data and Messaging

- **Azure SQL** for command/write persistence
- **Azure Cosmos DB** for read model storage
- **Azure Service Bus** (namespace + queue) for asynchronous integration
- **Azure Key Vault** for secrets/certificates
- **Storage Account (Azure Files)** used by deployment/initialization scripts

### AI and Observability

- **Azure OpenAI (AI Foundry)** used by chatbot flows
- **Log Analytics + Application Insights**
- **Managed Prometheus + Managed Grafana**
- **Azure Monitor Action Group** for operational alert notifications

---

## 3) Source Code Architecture (`src/`)

The solution is organized by bounded contexts and runtime concerns.

### Command Context (`src/Command`)

- Layered projects: Domain, Application, Infrastructure, Presentation, SharedKernel, Database
- `Presentation/Startup.cs` configures:
	- SQL Server DbContext (`ConnectionStrings:SpeechDB`)
	- Event sourcing infrastructure
	- Producer + Service Bus integration
- Responsibility: process create/update/delete commands and publish integration/domain events

### Broker Context (`src/broker`)

- Worker service + consumer/producer/service bus/cosmos/projection libraries
- `WorkerService/Program.cs` configures:
	- Hosted worker
	- Service Bus consumer
	- Cosmos dependencies
	- SignalR client integration (hub endpoint)
- Responsibility: consume queued events and project them to read models

### Query Context (`src/Query`)

- Layered projects: ReadModel, Application, Infrastructure, Presentation
- `Presentation/Startup.cs` configures Cosmos access with `DefaultAzureCredential`
	- Supports managed identity via `AZURE_CLIENT_ID` / `AZURE_TENANT_ID`
- Responsibility: expose read/query APIs over projected data

### Hub Context (`src/Hub`)

- SignalR server (`LogCorner.EduSync.Notification.Server`)
- Maps hub endpoint: `/logcornerhub`
- Responsibility: push near-real-time updates to clients

### Front Context (`src/Front`)

- ASP.NET front-end app
- Uses configured endpoints for:
	- Command API
	- Query API
	- SignalR Hub
	- Chatbot API
- Responsibility: user interaction and orchestration of backend calls

### Chatbot Context (`src/Chatbot` + `src/ChatBotApp`)

- Chatbot service exposes HTTP API for conversational use cases
- Development console app demonstrates Azure OpenAI client usage

---

## 4) Runtime Data Flow

Based on `dataflow.drawio` and service startup wiring.

1. External clients enter through **Application Gateway for Containers** (WAF + TLS).
2. Traffic is routed to services in **AKS**.
3. **Command API** persists write state to **Azure SQL**.
4. Command/API workflow publishes events to **Service Bus**.
5. **Worker/Broker** consumes events and updates **Cosmos DB** read projections.
6. **Query API** serves read requests from Cosmos DB.
7. **SignalR Hub** notifies front-end clients of updates.
8. **Front-end** refreshes via Query API and receives push events from hub.
9. **Chatbot service** invokes **Azure OpenAI** for AI inference.

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

## 5) Deployment View

### Infrastructure as Code

- Primary IaC entrypoint: `iac/bicep/main.bicep`
- Parameters: `iac/bicep/main.bicepparam`

Example deployment command:

```powershell
$resourceGroupName = "RG-EVENT-DRIVEN-ARCHITECTURE"

New-AzResourceGroupDeployment `
	-Name "DATASYNCHRO-EVENT-DRIVEN" `
	-ResourceGroupName $resourceGroupName `
	-TemplateFile iac/bicep/main.bicep `
	-TemplateParameterFile iac/bicep/main.bicepparam `
	-DeploymentDebugLogLevel All
```

### Application Packaging and Release

- Container build/push script at repository root
- Helm chart under `helm-chart/chart/logcorner.edusync.speech`
- Workload identity values and gateway integration configured in chart values

---

## 6) Security and Identity Model

- Managed identity is used by workloads for Azure resource access
- Query service uses `DefaultAzureCredential` with managed identity options
- Key Vault integration exists in command/query startup paths for non-development environments
- Ingress path is protected by WAF-enabled gateway

### Security Principles

- **No public endpoints** for core data/messaging services; private endpoint-first design
- **Passwordless authentication** using workload/managed identities wherever possible
- **Network isolation** via hub-spoke topology and subnet segregation
- **Ingress hardening** through WAF policy on Application Gateway for Containers
- **Centralized secret handling** through Azure Key Vault

---

## 7) Observability Model

- Service-level logging configured through standard ASP.NET/Serilog configuration files
- Platform monitoring stack includes:
	- Application Insights
	- Log Analytics
	- Managed Prometheus
	- Managed Grafana

---

## 8) Project-to-Component Mapping

| Runtime Component | Main Source Location |
|---|---|
| Command API | `src/Command/LogCorner.EduSync.Speech.Presentation` |
| Query API | `src/Query/LogCorner.EduSync.Speech.Presentation` |
| Broker Worker | `src/broker/LogCorner.EduSync.Speech.WorkerService` |
| SignalR Hub | `src/Hub/LogCorner.EduSync.Notification.Server` |
| Front-End | `src/Front/LogCorner.EduSync.Speech.Presentation` |
| Chatbot API | `src/Chatbot/LogCorner.EduSync.Speech.ChatBotService` |
| SQL Schema/Data Project | `src/LogCorner.EduSync.Speech.Database` and `src/Command/LogCorner.EduSync.Speech.Database` |

---

## 9) Architectural Characteristics

- **Event-driven** integration across command and projection paths
- **CQRS separation** between write and read models
- **Cloud-native deployment** on AKS via Helm and Bicep
- **Identity-first access** to Azure resources using managed identities
- **Operational visibility** via Azure-native monitoring stack

