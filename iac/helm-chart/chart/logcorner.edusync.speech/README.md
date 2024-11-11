A chart is a definition of the application and a release is an instance of a chart
we can install a new release of a revision of an existing release


Action
Install a Release
Upgrade a Release revision
Rollback to a Release revision
Print Release history
Display Release status
Show details of a release
Uninstall a Release
List Releases
Command
helm install [release] [chart]
helm upgrade [release] [chart]
helm rollback [release] [revision]
helm history [release]
helm status [release]
helm get all [release]
helm uninstall [release]
helm list


#install helm 
https://helm.sh/docs/intro/install/

helm version --short
kubectl config view

helm repo add "stable" "https://charts.helm.sh/stable"

helm env

# enable ingress
# add helm.kubernetes.docker.com to host

choco install kubernetes-helm


helm install [release] [chart]
helm install  logcorner-command  logcorner.edusync.speech

helm list --short  => list release name

helm get manifest logcorner-command

http://51.8.20.211/swagger/index.html

http://10.10.1.7/WeatherForecast

http://logcorner-command-http-api-service/WeatherForecast

https://helm.kubernetes.docker.com/speech-command-http-api/swagger/index.html


#UPGRADE RELEASE
update appVersion: "1.1"  and description 
version: 1.0.0 do not change  because chart is unchanged
change image version 
run the command

helm upgrade logcorner-command  logcorner.edusync.speech

helm rollback logcorner-command 1

helm history logcorner-command 

helm uninstall logcorner-command  logcorner.edusync.speech



# grafana

kubectl get pvc --namespace=helm -o wide

password admin/admin =>  admin/Grafana1#



# test
http://57.152.95.62/swagger/index.html
{
  "title": "Lorem Ipsum is simply dummy text",
  "description": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. ",
  "url": "http://test.com",
  "type": 3
}


curl -X 'POST' \
  'http://57.152.95.62/api/speech' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "title": "2_Lorem Ipsum is simply dummy text",
  "description": "2_Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry'\''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. ",
  "url": "http://2_test.com",
  "type": 2
}'

kubectl describe secret mssql -n helm
kubectl get secret mssql -n helm -o=jsonpath='{.data.DB_PASSWORD}' | base64 --decode

kubectl exec -it <other-pod-name> -n helm -- /bin/sh


# ingress nginx


helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace helm --create-namespace

##  ou

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"="true" \
  --set controller.service.type=LoadBalancer


kubectl exec -it curl-test -n helm -- /bin/sh

kubectl exec -it curl-test -n helm -- curl http://logcorner-command-http-api-service/WeatherForecast

kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx


curl http://10.10.1.7/speech-command-http-api/WeatherForecast


 kubectl exec -it curl-test -n helm -- curl http://logcorner-command-http-api-service/WeatherForecast


  kubectl exec -it curl-test -n helm -- curl http://10.10.1.7/WeatherForecast

   kubectl exec -it curl-test -n helm -- curl http://10.10.1.7/hello-world-two
    kubectl exec -it curl-test -n helm -- curl http://10.10.1.7/hello-world-one

     kubectl exec -it curl-test -n helm -- curl http://10.10.1.7/aks-command-api/WeatherForecast

   # ingress tutorial

   helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

   kubectl get pods --namespace ingress-nginx

   kubectl get service ingress-nginx-controller --namespace=ingress-nginx


   # https://spacelift.io/blog/kubernetes-ingress
#  helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
#  kubectl get pods --namespace ingress-nginx
# kubectl get service ingress-nginx-controller --namespace=ingress-nginx
#

# INTERNAL_IP ==> 
# helm install ingress-nginx ingress-nginx/ingress-nginx \
#   --namespace ingress-nginx \
#   --create-namespace \
#   --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"="true" \
#   --set controller.service.type=LoadBalancer




{{- /*
 INTERNAL_IP with static ip ==> 
  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.loadBalancerIP=10.10.1.7 \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"="true" 
*/ -}}



curl -X 'POST' \
  'http://10.10.1.7/aks-command-api/api/speech' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "title": "2_Lorem Ipsum is simply dummy text",
  "description": "2_Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry'\''s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. ",
  "url": "http://2_test.com",
  "type": 2
}'