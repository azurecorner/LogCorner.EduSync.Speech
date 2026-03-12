param( 
    [string]$acrName = "datasynchroacr"
)
# Set the ACR name and log in
$acrName = "datasynchroacr"
$accessToken = az acr login --name $acrName --expose-token --output tsv --query accessToken

# Lancer docker login avec token
docker login "$acrName.azurecr.io" `
  --username "00000000-0000-0000-0000-000000000000" `
  --password $accessToken


 # Build and push the SignalR HUB image
docker build -t "$acrName.azurecr.io/signalr-hub:latest" -f .\src\Hub\LogCorner.EduSync.Notification.Server\Dockerfile .\src\  --no-cache
docker push "$acrName.azurecr.io/signalr-hub:latest"

# Build and push the Web API command image
docker build -t "$acrName.azurecr.io/web-api-command:latest" -f .\src\Command\LogCorner.EduSync.Speech.Presentation\Dockerfile .\src\ 
docker push "$acrName.azurecr.io/web-api-command:latest"


# Build and push the Broker Service image
docker build -t "$acrName.azurecr.io/broker-app:latest" -f .\src\broker\LogCorner.EduSync.Speech.WorkerService\Dockerfile .\src\ 
docker push "$acrName.azurecr.io/broker-app:latest"


# Build and push the Web API query image
docker build -t "$acrName.azurecr.io/web-api-query:latest" -f .\src\Query\LogCorner.EduSync.Speech.Presentation\Dockerfile .\src\ 
docker push "$acrName.azurecr.io/web-api-query:latest"


# Build and push the Web App image
docker build -t "$acrName.azurecr.io/web-app:latest" -f .\src\Front\LogCorner.EduSync.Speech.Presentation\Dockerfile .\src\ --no-cache
docker push "$acrName.azurecr.io/web-app:latest"



# Build and push the Chat Bot image C:\Users\logcorner\source\repos\LogCorner.EduSync.Speech\src\Chatbot\LogCorner.EduSync.Speech.ChatBotService\Dockerfile
docker build -t "$acrName.azurecr.io/chat-bot:latest" -f .\src\Chatbot\LogCorner.EduSync.Speech.ChatBotService\Dockerfile .\src\ --no-cache
docker push "$acrName.azurecr.io/chat-bot:latest"

