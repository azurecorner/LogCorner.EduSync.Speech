# Install kubectl
az aks install-cli --only-show-errors

clusterName=datasynchro-aks-002
resourceGroupName=RG-EVENT-DRIVEN-ARCHITECTURE
subscriptionId=023b2039-5c23-44b8-844e-c002f8ed431d
# Get AKS credentials
az aks get-credentials \
  --admin \
  --name $clusterName \
  --resource-group $resourceGroupName \
  --subscription $subscriptionId \
  --only-show-errors

# Check if the cluster is private or not
private=$(az aks show --name $clusterName \
  --resource-group $resourceGroupName \
  --subscription $subscriptionId \
  --query apiServerAccessProfile.enablePrivateCluster \
  --output tsv)

# Install Helm


# Add Helm repos

helm repo add jetstack https://charts.jetstack.io

# Update Helm repos
helm repo update

# initialize variables
applicationGatewayForContainersName=appgwforcon-datasynchro
diagnosticSettingName="DefaultDiagnosticSettings"

if [[ $private == 'true' ]]; then
  # Log whether the cluster is public or private
  echo "$clusterName AKS cluster is private"

  # Install Prometheus


  # Install certificate manager


  # Create cluster issuer


 # Create service account
 kubectl apply -f serviceAccount.yaml

 kubectl get serviceaccount datasynchro-sa -n appgw-for-con-infra

# 
AKS_NAME=datasynchro-aks-002
RESOURCE_GROUP=RG-EVENT-DRIVEN-ARCHITECTURE
az aks show -n "$AKS_NAME" -g "$RESOURCE_GROUP" --query "oidcIssuerProfile.issuerUrl" -o tsv

IDENTITY_RESOURCE_NAME=appgwforcon-datasynchroManagedIdentity
az identity federated-credential list \
  --identity-name "$IDENTITY_RESOURCE_NAME" \
  --resource-group "$RESOURCE_GROUP"


    
    # Install the Application Load Balancer Controller
applicationGatewayForContainersNamespace=azure-alb-system
applicationGatewayForContainersManagedIdentityClientId=$(az identity show -g $resourceGroupName -n appgwforcon-datasynchroManagedIdentity --query clientId -o tsv)
  helm upgrade alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller \
    --install \
    --create-namespace \
    --namespace $applicationGatewayForContainersNamespace \
    --version 1.0.0 \
    --set albController.podIdentity.clientID=$applicationGatewayForContainersManagedIdentityClientId 

az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller --version 1.0.0  --set albController.podIdentity.clientID=$(az identity show -g $resourceGroupName -n appgwforcon-datasynchroManagedIdentity --query clientId -o tsv)
    # Create workload namespace
    command="kubectl create namespace alb-infra"

    az aks command invoke \
    --name $clusterName \
    --resource-group $resourceGroupName \
    --subscription $subscriptionId \
    --command "$command"

    if [[ "$applicationGatewayForContainersType" == "managed" ]]; then
      # Define the ApplicationLoadBalancer resource, specifying the subnet ID the Application Gateway for Containers association resource should deploy into. 
      # The association establishes connectivity from Application Gateway for Containers to the defined subnet (and connected networks where applicable) to 
      # be able to proxy traffic to a defined backend.
      command="kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: ApplicationLoadBalancer
metadata:
  name: alb
  namespace: alb-infra
spec:
  associations:
  - $applicationGatewayForContainersSubnetId
EOF"
      az aks command invoke \
      --name $clusterName \
      --resource-group $resourceGroupName \
      --subscription $subscriptionId \
      --command "$command"

      if [[ -n $nodeResourceGroupName ]]; then \
        echo -n "Retrieving the resource id of the Application Gateway for Containers..."
        counter=1
        while [ $counter -le 600 ]
        do
          # Retrieve the resource id of the managed Application Gateway for Containers resource
          applicationGatewayForContainersId=$(az resource list \
            --resource-type "Microsoft.ServiceNetworking/TrafficControllers" \
            --resource-group $nodeResourceGroupName \
            --query [0].id \
            --output tsv)
          if [[ -n $applicationGatewayForContainersId ]]; then
            echo 
            break 
          else
            echo -n '.'
            counter=$((counter + 1))
            sleep 1
          fi
        done

        if [[ -n $applicationGatewayForContainersId ]]; then
          applicationGatewayForContainersName=$(basename $applicationGatewayForContainersId)
          echo "[$applicationGatewayForContainersId] resource id of the [$applicationGatewayForContainersName] Application Gateway for Containers successfully retrieved"
        else
          echo "Failed to retrieve the resource id of the Application Gateway for Containers"
          exit -1
        fi

        # Check if the diagnostic setting already exists for the Application Gateway for Containers
        echo "Checking if the [$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers actually exists..."
        result=$(az monitor diagnostic-settings show \
          --name $diagnosticSettingName \
          --resource $applicationGatewayForContainersId \
          --query name \
          --output tsv 2>/dev/null)

        if [[ -z $result ]]; then
          echo "[$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers does not exist"
          echo "Creating [$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers..."

          # Create the diagnostic setting for the Application Gateway for Containers
          az monitor diagnostic-settings create \
            --name $diagnosticSettingName \
            --resource $applicationGatewayForContainersId \
            --logs '[{"categoryGroup": "allLogs", "enabled": true}]' \
            --metrics '[{"category": "AllMetrics", "enabled": true}]' \
            --workspace $workspaceId \
            --only-show-errors 1>/dev/null

          if [[ $? == 0 ]]; then
            echo "[$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers successfully created"
          else
            echo "Failed to create [$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers"
            exit -1
          fi
        else
          echo "[$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers already exists"
        fi
      fi
    fi
  fi
else
  # Log whether the cluster is public or private
  echo "$clusterName AKS cluster is public"

  # Install Prometheus
  echo "Installing Prometheus..."
  helm upgrade prometheus prometheus-community/kube-prometheus-stack \
    --install \
    --create-namespace \
    --namespace prometheus \
    --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

  if [[ $? == 0 ]]; then
    echo "Prometheus successfully installed"
  else
    echo "Failed to install Prometheus"
    exit -1
  fi

  # Install NGINX ingress controller using the internal load balancer
  echo "Installing NGINX ingress controller..."
  helm upgrade nginx-ingress ingress-nginx/ingress-nginx \
    --install \
    --create-namespace \
    --namespace ingress-basic \
    --set controller.replicaCount=3 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.metrics.enabled=true \
    --set controller.metrics.serviceMonitor.enabled=true \
    --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

  if [[ $? == 0 ]]; then
    echo "NGINX ingress controller successfully installed"
  else
    echo "Failed to install NGINX ingress controller"
    exit -1
  fi

  # Install certificate manager
  echo "Installing certificate manager..."
  helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --create-namespace \
    --namespace cert-manager \
    --version v1.14.0 \
    --set installCRDs=true \
    --set nodeSelector."kubernetes\.io/os"=linux \
    --set "extraArgs={--feature-gates=ExperimentalGatewayAPISupport=true}"

  if [[ $? == 0 ]]; then
    echo "Certificate manager successfully installed"
  else
    echo "Failed to install certificate manager"
    exit -1
  fi

  # Create cluster issuer
  echo "Creating cluster issuer..."
  cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-nginx
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $email
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: nginx
          podTemplate:
            spec:
              nodeSelector:
                "kubernetes.io/os": linux
EOF

  if [[ -n "$namespace" && \
        -n "$serviceAccountName" ]]; then
    # Create workload namespace
    result=$(kubectl get namespace -o 'jsonpath={.items[?(@.metadata.name=="'$namespace'")].metadata.name'})

    if [[ -n $result ]]; then
        echo "$namespace namespace already exists in the cluster"
    else
        echo "$namespace namespace does not exist in the cluster"
        echo "Creating $namespace namespace in the cluster..."
        kubectl create namespace $namespace
    fi

    # Create service account
    echo "Creating $serviceAccountName service account..."
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: $workloadManagedIdentityClientId
    azure.workload.identity/tenant-id: $tenantId
  labels:
    azure.workload.identity/use: "true"
  name: $serviceAccountName
  namespace: $namespace
EOF
  fi

  if [[ "$applicationGatewayForContainersEnabled" == "true" \
        && -n "$applicationGatewayForContainersManagedIdentityClientId" \
        && -n "$applicationGatewayForContainersSubnetId" ]]; then
      
      # Install the Application Load Balancer
      echo "Installing Application Load Balancer Controller in $applicationGatewayForContainersNamespace namespace using $applicationGatewayForContainersManagedIdentityClientId managed identity..."
      helm upgrade alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller \
      --install \
      --create-namespace \
      --namespace $applicationGatewayForContainersNamespace \
      --version 1.0.0 \
      --set albController.namespace=$applicationGatewayForContainersNamespace \
      --set albController.podIdentity.clientID=$applicationGatewayForContainersManagedIdentityClientId
    
    if [[ $? == 0 ]]; then
      echo "Application Load Balancer Controller successfully installed"
    else
      echo "Failed to install Application Load Balancer Controller"
      exit -1
    fi

    if [[ "$applicationGatewayForContainersType" == "managed" ]]; then
      # Create alb-infra namespace
      albInfraNamespace='alb-infra'
      result=$(kubectl get namespace -o 'jsonpath={.items[?(@.metadata.name=="'$albInfraNamespace'")].metadata.name'})

      if [[ -n $result ]]; then
          echo "$albInfraNamespace namespace already exists in the cluster"
      else
          echo "$albInfraNamespace namespace does not exist in the cluster"
          echo "Creating $albInfraNamespace namespace in the cluster..."
          kubectl create namespace $albInfraNamespace
      fi

      # Define the ApplicationLoadBalancer resource, specifying the subnet ID the Application Gateway for Containers association resource should deploy into. 
      # The association establishes connectivity from Application Gateway for Containers to the defined subnet (and connected networks where applicable) to 
      # be able to proxy traffic to a defined backend.
      echo "Creating ApplicationLoadBalancer resource..."
      kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: ApplicationLoadBalancer
metadata:
  name: alb
  namespace: alb-infra
spec:
  associations:
  - $applicationGatewayForContainersSubnetId
EOF
      if [[ -n $nodeResourceGroupName ]]; then \
        echo -n "Retrieving the resource id of the Application Gateway for Containers..."
        counter=1
        while [ $counter -le 20 ]
        do
          # Retrieve the resource id of the managed Application Gateway for Containers resource
          applicationGatewayForContainersId=$(az resource list \
            --resource-type "Microsoft.ServiceNetworking/TrafficControllers" \
            --resource-group $nodeResourceGroupName \
            --query [0].id \
            --output tsv)
          if [[ -n $applicationGatewayForContainersId ]]; then
            echo 
            break 
          else
            echo -n '.'
            counter=$((counter + 1))
            sleep 1
          fi
        done

        if [[ -n $applicationGatewayForContainersId ]]; then
          applicationGatewayForContainersName=$(basename $applicationGatewayForContainersId)
          echo "[$applicationGatewayForContainersId] resource id of the [$applicationGatewayForContainersName] Application Gateway for Containers successfully retrieved"
        else
          echo "Failed to retrieve the resource id of the Application Gateway for Containers"
          exit -1
        fi

        # Check if the diagnostic setting already exists for the Application Gateway for Containers
        echo "Checking if the [$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers actually exists..."
        result=$(az monitor diagnostic-settings show \
          --name $diagnosticSettingName \
          --resource $applicationGatewayForContainersId \
          --query name \
          --output tsv 2>/dev/null)

        if [[ -z $result ]]; then
          echo "[$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers does not exist"
          echo "Creating [$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers..."

          # Create the diagnostic setting for the Application Gateway for Containers
          az monitor diagnostic-settings create \
            --name $diagnosticSettingName \
            --resource $applicationGatewayForContainersId \
            --logs '[{"categoryGroup": "allLogs", "enabled": true}]' \
            --metrics '[{"category": "AllMetrics", "enabled": true}]' \
            --workspace $workspaceId \
            --only-show-errors 1>/dev/null

          if [[ $? == 0 ]]; then
            echo "[$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers successfully created"
          else
            echo "Failed to create [$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers"
            exit -1
          fi
        else
          echo "[$diagnosticSettingName] diagnostic setting for the [$applicationGatewayForContainersName] Application Gateway for Containers already exists"
        fi
      fi
    fi
  fi
fi

# Create output as JSON file
echo '{}' |
  jq --arg x $applicationGatewayForContainersName '.applicationGatewayForContainersName=$x' |
  jq --arg x $namespace '.namespace=$x' |
  jq --arg x $serviceAccountName '.serviceAccountName=$x' |
  jq --arg x 'prometheus' '.prometheus=$x' |
  jq --arg x 'cert-manager' '.certManager=$x' |
  jq --arg x 'ingress-basic' '.nginxIngressController=$x' >$AZ_SCRIPTS_OUTPUT_PATH