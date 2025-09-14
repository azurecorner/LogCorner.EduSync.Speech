namespace LogCorner.EduSync.Speech.CosmosDb
{
    public interface IDataService
    {
        Task CreateAsync<T>(Func<string, Task> writeOutputAync, T item, string partitionKeyValue);

        Task<T> ReadAsync<T>(Func<string, Task> writeOutputAync, string id, string partitionKey);

        Task<T> ReadAsync<T>(Func<string, Task> writeOutputAync, string id);

        Task<List<T>> ReadAsync<T>(Func<string, Task> writeOutputAync);

        string GetEndpoint();
    }
}