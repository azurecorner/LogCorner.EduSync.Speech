# Helm Chart Guide: `logcorner.edusync.speech`

A chart is the application template. A release is one deployed instance of that chart.

## Prerequisites

- Install Helm: https://helm.sh/docs/intro/install/
- Verify tools:
	- `helm version --short`
	- `kubectl config view`
	- `helm env`

## Common Helm Commands

- Install: `helm install <release> <chart>`
- Upgrade: `helm upgrade <release> <chart>`
- Rollback: `helm rollback <release> <revision>`
- History: `helm history <release>`
- Status: `helm status <release>`
- Get manifest: `helm get manifest <release>`
- Uninstall: `helm uninstall <release>`
- List releases: `helm list --short`

## Deploy This Chart

From `helm-chart/chart`:

- Validate templates first:
	- `helm template logcorner-command ./logcorner.edusync.speech`
- Install first time:
	- `helm install logcorner-command ./logcorner.edusync.speech`
- Upgrade existing release:
	- `helm upgrade logcorner-command ./logcorner.edusync.speech`

## Deploy With Runtime Overrides

Use this when values come from scripts/environment:

`helm upgrade --install logcorner-command ./logcorner.edusync.speech --set azureWorkloadIdentityClientId=$USER_ASSIGNED_CLIENT_ID --set applicationGatewayForContainerResourceId=$ApplicationForContainerResourceId --set tenantId=$KEYVAULT_TENANT`

## Operations

- Show rendered manifest for deployed release:
	- `helm get manifest logcorner-command`
- Rollback to revision 1:
	- `helm rollback logcorner-command 1`
- Uninstall release:
	- `helm uninstall logcorner-command`

## Notes

- Most chart settings are now value-driven; prefer updating `values.yaml` files instead of hardcoding templates.
- If `helm upgrade` fails, run `helm template` first to catch YAML/template issues quickly.