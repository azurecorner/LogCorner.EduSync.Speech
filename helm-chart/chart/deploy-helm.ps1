
$NAMESPACE = "azure-workloads"
$RELEASE_NAME = "logcorner-command"

az aks get-credentials --resource-group RG-EVENT-DRIVEN-ARCHITECTURE --name datasynchro-aks --overwrite-existing

choco install kubernetes-cli azure-kubelogin

helm repo add "stable" "https://charts.helm.sh/stable"

kubelogin convert-kubeconfig -l azurecli

helm upgrade --install  $RELEASE_NAME  logcorner.edusync.speech

kubectl get pods -n $NAMESPACE

kubectl get svc -n $NAMESPACE

kubectl get sa -n $NAMESPACE

kubectl rollout restart deployment -n $NAMESPACE

kubectl get pods -n $NAMESPACE

# helm uninstall $RELEASE_NAME  logcorner.edusync.speech

kubectl logs web-frontend-app-5d9cd74745-hbnrh -n $NAMESPACE