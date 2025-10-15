RESOURCE_GROUP=RG-EVENT-DRIVEN-ARCHITECTURE
AKS_NAME=datasynchro-aks
IDENTITY_RESOURCE_NAME=azure-alb-identity
AGFC_NAME=appgwforcon-datasynchro
FRONTEND_NAME='test-frontend'

# https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller?tabs=install-helm-linux
# create front end 
az network alb frontend create -g $RESOURCE_GROUP -n $FRONTEND_NAME --alb-name $AGFC_NAME

# Create association between ALB and subnet
ASSOCIATION_NAME='association-test'
VNET_NAME=datasynchro-vnet
ALB_SUBNET_NAME=appgwforcontainers-subnet
ALB_SUBNET_ID=$(az network vnet subnet list --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --query "[?name=='$ALB_SUBNET_NAME'].id" --output tsv)
echo $ALB_SUBNET_ID
az network alb association create -g $RESOURCE_GROUP -n $ASSOCIATION_NAME --alb-name $AGFC_NAME --subnet $ALB_SUBNET_ID

# Install the ALB Controller~Install the ALB Controller
#

# mcResourceGroup=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "nodeResourceGroup" -o tsv)
# mcResourceGroupId=$(az group show --name $mcResourceGroup --query id -otsv)

# echo "Creating identity $IDENTITY_RESOURCE_NAME in resource group $RESOURCE_GROUP"

# principalId="$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)"

# echo "Waiting 60 seconds to allow for replication of the identity..."
# sleep 60


HELM_NAMESPACE='azure-alb-resource' #'<namespace for deployment>'
CONTROLLER_NAMESPACE='azure-alb-system'

az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
kubectl create namespace $HELM_NAMESPACE
kubectl create namespace $CONTROLLER_NAMESPACE

helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller --namespace $HELM_NAMESPACE --version 1.7.7 --set albController.namespace=$CONTROLLER_NAMESPACE --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n azure-alb-identity --query clientId -o tsv)