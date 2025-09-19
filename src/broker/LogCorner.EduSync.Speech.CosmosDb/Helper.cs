using Microsoft.Azure.Cosmos;

namespace LogCorner.EduSync.Speech.CosmosDb.Helpers
{
    internal static class Helper
    {
        public static async Task<T?> TryReadItemAsync<T>(
    this Container container,
    string id,
    string partitionKeyValue,
    Func<string, Task> writeOutputAsync
)
        {
            try
            {
                var response = await container.ReadItemAsync<T>(
                    id,
                    new PartitionKey(partitionKeyValue)
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