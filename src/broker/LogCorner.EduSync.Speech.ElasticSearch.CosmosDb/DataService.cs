using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;

namespace Logistic.Infrastructure.cosmos
{
    public sealed class DataService(CosmosClient client, IConfiguration configurationOptions) : IDataService
    {
        public string GetEndpoint() => $"{client.Endpoint}";

        private string databaseName = configurationOptions["AzureCosmosDB:DatabaseName"] ?? throw new ArgumentNullException("AzureCosmosDB:DatabaseName");
        private string ContainerName = configurationOptions["AzureCosmosDB:ContainerName"] ?? throw new ArgumentNullException("AzureCosmosDB:ContainerName");

        public async Task CreateAsync<T>(Func<string, Task> writeOutputAsync, T item, string partitionKeyValue)
        {
            try
            {
                Database database = client.GetDatabase(databaseName);

                // Ensure the container exists
                ContainerResponse containerResponse = await database.CreateContainerIfNotExistsAsync(
                    id: ContainerName,
                    partitionKeyPath: "/Client"
                );

                Container container = database.GetContainer(ContainerName);

                // Upsert item with partition key
                ItemResponse<T> response = await container.UpsertItemAsync(
                    item: item,
                    partitionKey: new PartitionKey(partitionKeyValue)
                );

                // Logging
                await writeOutputAsync($"Upserted item ID: {response.Resource}");
                await writeOutputAsync($"Status code: {response.StatusCode}");
                await writeOutputAsync($"Request charge: {response.RequestCharge:0.00}");
                await writeOutputAsync($"Status Code: {response.ActivityId}");
                Console.WriteLine("DataService::CreateAsync => successfull ");
            }
            catch (Exception ex)
            {
                await writeOutputAsync($"Error: {ex.Message}");
            }
        }

        public async Task<T> ReadAsync<T>(Func<string, Task> writeOutputAync, string id, string partitionKey)
        {
            Database database = client.GetDatabase(databaseName);

            database = await database.ReadAsync();
            await writeOutputAync($"Get database:\t{database.Id}");

            Container container = database.GetContainer(ContainerName);

            container = await container.ReadContainerAsync();
            await writeOutputAync($"Get container:\t{container.Id}");

            ItemResponse<T> response = await container.ReadItemAsync<T>(
               id: id,
                   partitionKey: new PartitionKey(partitionKey)
               );

            await writeOutputAync($"Read item id:\t{response.Resource}");

            return response.Resource;
        }

        public async Task<T> ReadAsync<T>(Func<string, Task> writeOutputAync, string id)
        {
            Database database = client.GetDatabase(databaseName);

            database = await database.ReadAsync();
            await writeOutputAync($"Get database:\t{database.Id}");

            Container container = database.GetContainer(ContainerName);

            container = await container.ReadContainerAsync();
            await writeOutputAync($"Get container:\t{container.Id}");

            // Build query definition
            var parameterizedQuery = new QueryDefinition(
                query: $"SELECT * FROM {container.Id} p WHERE p.id = @id"
            )
                .WithParameter("@id", id);

            // Query multiple items from container
            using FeedIterator<T> filteredFeed = container.GetItemQueryIterator<T>(
                queryDefinition: parameterizedQuery
            );

            var result = await filteredFeed.ReadNextAsync();
            return result.FirstOrDefault() ?? default!;
        }

        public async Task<List<T>> ReadAsync<T>(Func<string, Task> writeOutputAync)
        {
            try
            {
                Database database = client.GetDatabase(databaseName);

                database = await database.ReadAsync();
                await writeOutputAync($"Get database:\t{database.Id}");

                Container container = database.GetContainer(ContainerName);

                container = await container.ReadContainerAsync();
                await writeOutputAync($"Get container:\t{container.Id}");
                var query = new QueryDefinition(
                     query: $"SELECT * FROM {container.Id}"
                 );

                using FeedIterator<T> feed = container.GetItemQueryIterator<T>(
                    queryDefinition: query
                );

                await writeOutputAync($"Ran query:\t{query.QueryText}");

                List<T> items = new();
                double requestCharge = 0d;
                while (feed.HasMoreResults)
                {
                    FeedResponse<T> response = await feed.ReadNextAsync();
                    foreach (T item in response)
                    {
                        items.Add(item);
                    }
                    requestCharge += response.RequestCharge;
                }

                return items;
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                Console.WriteLine($"Container '{ContainerName}' does not exist.");
                return new List<T>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                throw;
            }
        }
    }
}