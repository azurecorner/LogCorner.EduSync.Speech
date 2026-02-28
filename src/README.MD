# Develop locally using the Azure Cosmos DB emulator

https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-develop-emulator?tabs=docker-linux%2Ccsharp&pivots=api-nosqlTo develop locally using the Azure Cosmos DB emulator, you can use the following Docker command to pull the latest image of the emulator:	

docker pull mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest

docker run `
    --publish 8081:8081 `
    --publish 10250-10255:10250-10255 `
    --name linux-emulator `
    --detach `
    mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest

# Check if the emulator responds
curl -k https://localhost:8081/_explorer/emulator.pem

# Expected: Returns emulator info/HTML page


# Response
https://localhost:8081/_explorer/index.html

