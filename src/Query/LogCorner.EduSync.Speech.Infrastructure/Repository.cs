using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace LogCorner.EduSync.Speech.Infrastructure
{
    public class Repository : IRepository
    {
        private string databaseName;
        private string ContainerName;
        private readonly CosmosClient _cosmosClient;

        public Repository(CosmosClient cosmosClient, IConfiguration configuration)
        {
            _cosmosClient = cosmosClient;
            databaseName = configuration["AzureCosmosDB:DatabaseName"] ?? throw new ArgumentNullException("AzureCosmosDB:DatabaseName");
            ContainerName = configuration["AzureCosmosDB:ContainerName"] ?? throw new ArgumentNullException("AzureCosmosDB:ContainerName");
        }

        public async Task<List<T>> ReadAsync<T>(Func<string, Task> writeOutputAync)
        {
            try
            {
                Database database = _cosmosClient.GetDatabase(databaseName);

                database = await database.ReadAsync();
                await writeOutputAync($"Get database:\t{database.Id}");

                var container = database.GetContainer(ContainerName);

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

        public async Task<T?> TryReadItemAsync<T>(string id, Func<string, Task> writeOutputAsync)
        {
            try
            {
                Database database = _cosmosClient.GetDatabase(databaseName);

                var container = database.GetContainer(ContainerName);

                var response = await container.ReadItemAsync<T>(
                    id,
                    new PartitionKey(id)
                );
                return response.Resource;
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                await writeOutputAsync($"No non-null fields to update for item ID: {id}");
                return default; // no exception → just return null
            }
        }
    }
}