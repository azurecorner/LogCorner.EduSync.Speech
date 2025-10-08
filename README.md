# LogCorner.EduSync
Building microservices through Event Driven Architecture

# Set the ACR name and log in
$acrName = "datasynchroacr"
az acr login --name $acrName

# Build and push the Web API image
docker build -t "$acrName.azurecr.io/web-api:latest" -f .\src\Command\LogCorner.EduSync.Speech.Presentation\Dockerfile .\src\ --no-cache
docker push "$acrName.azurecr.io/web-api:latest"

# Build and push the Web App image
docker build -t "$acrName.azurecr.io/web-app:latest" -f .\src\OtelReferenceApp\WebApp\Dockerfile .\src\OtelReferenceApp\ --no-cache
docker push "$acrName.azurecr.io/web-app:latest"


C:\Users\LEYE-GORA\source\repos\AZURE WARRIORS\EDA-FULL MICROSOFT\LogCorner.EduSync.Speech\src\Command\LogCorner.EduSync.Speech.Presentation\Dockerfile























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