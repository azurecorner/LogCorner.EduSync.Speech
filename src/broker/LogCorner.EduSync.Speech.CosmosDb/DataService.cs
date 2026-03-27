using LogCorner.EduSync.Speech.CosmosDb.Helpers;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;

namespace LogCorner.EduSync.Speech.CosmosDb
{
    public sealed class DataService : IDataService
    {
        private string databaseName;
        private string ContainerName;
        private readonly CosmosClient _cosmosClient;

        public DataService(CosmosClient cosmosClient, IConfiguration configuration)
        {
            _cosmosClient = cosmosClient;
            databaseName = configuration["AzureCosmosDB:DatabaseName"] ?? throw new ArgumentNullException("AzureCosmosDB:DatabaseName");
            ContainerName = configuration["AzureCosmosDB:ContainerName"] ?? throw new ArgumentNullException("AzureCosmosDB:ContainerName");
        }

        public async Task CreateAsync<T>(Func<string, Task> writeOutputAsync, T item, string partitionKeyValue)
        {
            Database database = _cosmosClient.GetDatabase(databaseName);

            Container container = database.GetContainer(ContainerName);

            string id = string.Empty;

            // Case 1: Dictionary<string, object>
            if (item is IDictionary<string, object> dict)
            {
                if (dict.TryGetValue("id", out var idValue) && idValue != null)
                {
                    id = idValue.ToString()!;
                }
            }

            if (string.IsNullOrWhiteSpace(id))
                throw new InvalidOperationException("Entity must have an 'id' property or dictionary key");

            try
            {
                var result = await container.TryReadItemAsync<T>(id, partitionKeyValue, writeOutputAsync);

                if (result == null)
                {
                    // Insert full item
                    ItemResponse<T> insertResponse = await container.CreateItemAsync(
                        item,
                        new PartitionKey(partitionKeyValue)
                    );

                    await writeOutputAsync($"Inserted new item ID: {id}");
                    await writeOutputAsync($"Status code: {insertResponse.StatusCode}");
                    await writeOutputAsync($"Request charge: {insertResponse.RequestCharge:0.00}");
                }
                else
                {
                    // Build patch ops only for non-null values
                    var patchOps = new List<PatchOperation>();

                    if (item is IDictionary<string, object> dictItem)
                    {
                        foreach (var kvp in dictItem)
                        {
                            if (string.Equals(kvp.Key, "id", StringComparison.OrdinalIgnoreCase))
                                continue;

                            if (kvp.Value != null)
                            {
                                patchOps.Add(PatchOperation.Set($"/{kvp.Key}", kvp.Value));
                            }
                        }
                    }

                    if (patchOps.Count > 0)
                    {
                        var patchResponse = await container.PatchItemAsync<T>(
                            id,
                            new PartitionKey(partitionKeyValue),
                            patchOps
                        );

                        await writeOutputAsync($"Patched item ID: {id}");
                        await writeOutputAsync($"Status code: {patchResponse.StatusCode}");
                        await writeOutputAsync($"Request charge: {patchResponse.RequestCharge:0.00}");
                    }
                    else
                    {
                        await writeOutputAsync($"No non-null fields to update for item ID: {id}");
                    }
                }
            }
            catch (CosmosException ex)
            {
                await writeOutputAsync($"Error: {ex.Message}");
                await writeOutputAsync($"Cosmos error: {ex.Message}");
                await writeOutputAsync($"StatusCode: {ex.StatusCode}");
                await writeOutputAsync($"SubStatusCode: {ex.SubStatusCode}");
                await writeOutputAsync($"ActivityId: {ex.ActivityId}");
                await writeOutputAsync($"Diagnostics: {ex.Diagnostics}");
                throw;
            }
        }

        public async Task<T> ReadAsync<T>(Func<string, Task> writeOutputAync, string id, string partitionKey)
        {
            Database database = _cosmosClient.GetDatabase(databaseName);

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
            Database database = _cosmosClient.GetDatabase(databaseName);

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
                Database database = _cosmosClient.GetDatabase(databaseName);

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

        public async Task DeleteAsync<T>(Func<string, Task> writeOutputAync, string id)
        {
            Database database = _cosmosClient.GetDatabase(databaseName);

            Container container = database.GetContainer(ContainerName);

            var result = await container.TryReadItemAsync<T>(id, id, writeOutputAync);

            if (result == null)
            {
                await writeOutputAync($"Item with id '{id}' does not exist. No deletion performed.");
                return;
            }

            var response = await container.DeleteItemAsync<T>(
               id: id,
                   partitionKey: new PartitionKey(id)
               );

            if (response.StatusCode == System.Net.HttpStatusCode.NoContent)
            {
                await writeOutputAync($"Item with id '{id}' deleted successfully.");
            }
            else
            {
                await writeOutputAync($"Failed to delete item with id '{id}'. Status code: {response.StatusCode}");
            }
        }
    }
}