namespace LogCorner.EduSync.Speech.CosmosDb
{
    using Microsoft.Azure.Cosmos;
    using System;
    using System.Collections.Generic;
    using System.Reflection;
    using System.Threading.Tasks;

    public static class CosmosDbExtensions
    {
        /// <summary>
        /// Inserts the item if it does not exist, or updates only the non-null fields if it exists.
        /// Existing fields not present in the object are left untouched.
        /// </summary>
        public static async Task UpsertNonNullAsync<T>(
            this Container container,
            T item,
            string partitionKeyValue,
            Func<string, Task> writeOutputAsync = null
        ) where T : class
        {
            // Resolve 'id' property
            var idProp = typeof(T).GetProperty("id", BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase)
                         ?? typeof(T).GetProperty("Id", BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);

            if (idProp == null)
                throw new InvalidOperationException("Entity must have an 'id' property");

            string id = idProp.GetValue(item)?.ToString();
            if (string.IsNullOrWhiteSpace(id))
                throw new InvalidOperationException("Entity id cannot be null or empty");

            // Check if item exists
            bool exists = false;
            try
            {
                await container.ReadItemAsync<T>(id, new PartitionKey(partitionKeyValue));
                exists = true;
            }
            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                exists = false;
            }

            if (!exists)
            {
                // Insert new item
                var insertResponse = await container.CreateItemAsync(item, new PartitionKey(partitionKeyValue));
                if (writeOutputAsync != null)
                    await writeOutputAsync($"Inserted item ID: {id}, RU: {insertResponse.RequestCharge:0.00}");
            }
            else
            {
                // Build patch operations for non-null properties
                var patchOps = new List<PatchOperation>();
                foreach (var prop in typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance))
                {
                    if (string.Equals(prop.Name, idProp.Name, StringComparison.OrdinalIgnoreCase))
                        continue;

                    var value = prop.GetValue(item);
                    if (value != null) // only update non-null fields
                        patchOps.Add(PatchOperation.Set($"/{prop.Name}", value));
                }

                if (patchOps.Count > 0)
                {
                    var patchResponse = await container.PatchItemAsync<T>(
                        id,
                        new PartitionKey(partitionKeyValue),
                        patchOps
                    );

                    if (writeOutputAsync != null)
                        await writeOutputAsync($"Patched item ID: {id}, RU: {patchResponse.RequestCharge:0.00}");
                }
                else
                {
                    if (writeOutputAsync != null)
                        await writeOutputAsync($"No non-null fields to patch for ID: {id}");
                }
            }
        }
    }
}