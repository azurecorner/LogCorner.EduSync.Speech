
#install helm 
https://helm.sh/docs/intro/install/

choco install kubernetes-helm

helm version --short
kubectl config view

helm repo add "stable" "https://charts.helm.sh/stable"

helm env


az account set --subscription 023b2039-5c23-44b8-844e-c002f8ed431d

az aks get-credentials --resource-group SRE-AGENT-MANAGED --name datasynchro-aks-002 --overwrite-existing

# under helm-chart\chart  folder

helm upgrade --install logcorner-command logcorner.edusync.speech

kubectl exec -it curl-test -n helm -- curl http://10.0.246.99/WeatherForecast


kubectl exec -i curl-test -n helm -- curl -v http://10.0.246.99/api/speech   -H "Content-Type: application/json"   -d '{"title":"test","description":"test","url":"http://test.com","type":3}'



kubectl exec -i curl-test -n helm -- curl -X POST http://10.0.87.232/api/speech \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "title": "3_Lorem Ipsum is simply dummy text",
  "description": "3_Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. ",
  "url": "http://3_test.com",
  "typeId": 1
}'

